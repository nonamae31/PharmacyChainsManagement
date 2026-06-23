using System;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Repositories;

namespace PharmacyChainsManagementBE.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly ISessionRepository _sessionRepository;
    private readonly ITokenService _tokenService;
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;
    private readonly IEmailService _emailService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly FounderSettings _founderSettings;
    private readonly IMemoryCache _memoryCache;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IUserRepository userRepository,
        ISessionRepository sessionRepository,
        ITokenService tokenService,
        IPasswordHashingStrategy passwordHashingStrategy,
        IEmailService emailService,
        IUnitOfWork unitOfWork,
        IOptions<FounderSettings> founderSettings,
        IMemoryCache memoryCache,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository;
        _sessionRepository = sessionRepository;
        _tokenService = tokenService;
        _passwordHashingStrategy = passwordHashingStrategy;
        _emailService = emailService;
        _unitOfWork = unitOfWork;
        _founderSettings = founderSettings.Value;
        _memoryCache = memoryCache;
        _logger = logger;
    }

    public async Task<Result<AuthResultResponse>> LoginAsync(
        LoginRequest request, 
        string? ipAddress, 
        string? userAgent, 
        string? deviceId, 
        CancellationToken cancellationToken)
    {
        Guid userId;
        UserResponse userDto;
        RoleResponse roleDto;

        // 1. Check Founder Login
        if (!string.IsNullOrEmpty(_founderSettings.Email) && request.Email.Equals(_founderSettings.Email, StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogInformation("Founder login attempt for email: {Email}", request.Email);
            
            bool isPasswordValid = _passwordHashingStrategy.VerifyPassword(request.Password, _founderSettings.PasswordHash);
            if (!isPasswordValid)
            {
                _logger.LogWarning("Founder login failed: Invalid credentials for email: {Email}", request.Email);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

            userId = Guid.Empty;
            userDto = new UserResponse(Guid.Empty, "Founder", _founderSettings.Email, null, null, "ACTIVE");
            roleDto = new RoleResponse(0, "FOUNDER", "Founder");
            _logger.LogInformation("Founder logged in successfully from IP: {IpAddress}", ipAddress);
        }
        else
        {
            // 2. Check regular DB User
            var user = await _userRepository.FindActiveByEmailAsync(request.Email, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("Login failed: User not found or inactive for email: {Email}", request.Email);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

            // 3. Check Lockout Status
            if (user.LockoutEnd.HasValue && user.LockoutEnd.Value > DateTime.UtcNow)
            {
                var timeLeft = user.LockoutEnd.Value - DateTime.UtcNow;
                _logger.LogWarning("Login failed: Account locked for email: {Email}. Lockout ends at {LockoutEnd}", request.Email, user.LockoutEnd.Value);
                return Result.Failure<AuthResultResponse>(Error.Validation(
                    "Auth.AccountLocked", 
                    $"Account is temporarily locked. Please try again in {Math.Ceiling(timeLeft.TotalMinutes)} minutes."));
            }

            // 4. Verify password
            bool isUserPasswordValid = _passwordHashingStrategy.VerifyPassword(request.Password, user.PasswordHash);
            if (!isUserPasswordValid)
            {
                user.AccessFailedCount++;
                _logger.LogWarning("Login failed: Invalid credentials for user: {Email}. Attempt: {Count}", request.Email, user.AccessFailedCount);

                if (user.AccessFailedCount >= 5)
                {
                    user.LockoutEnd = DateTime.UtcNow.AddMinutes(15);
                    _logger.LogWarning("Account locked for user: {Email} for 15 minutes due to 5 consecutive failures.", request.Email);
                    
                    await _userRepository.UpdateAsync(user, cancellationToken);
                    
                    return Result.Failure<AuthResultResponse>(Error.Validation(
                        "Auth.AccountLocked", 
                        "Account is temporarily locked for 15 minutes due to multiple failed login attempts."));
                }

                await _userRepository.UpdateAsync(user, cancellationToken);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

            // 5. Reset lockout counters on success
            user.AccessFailedCount = 0;
            user.LockoutEnd = null;
            await _userRepository.UpdateAsync(user, cancellationToken);

            userId = user.UserId;
            var userRoleCode = user.Role?.RoleCode ?? "USER";
            var userRoleName = user.Role?.RoleName ?? "User";
            var userRoleId = user.Role?.RoleId ?? 0;

            userDto = new UserResponse(user.UserId, user.FullName, user.Email, user.Phone, user.ProfilePhotoUri, user.Status);
            roleDto = new RoleResponse(userRoleId, userRoleCode, userRoleName);
            _logger.LogInformation("User {UserId} logged in successfully from IP: {IpAddress}", user.UserId, ipAddress);
        }

        // 6. Generate Tokens
        var accessToken = _tokenService.IssueJwt(userId, userDto.Email, roleDto.RoleCode);
        var refreshToken = _tokenService.GenerateRefreshToken();

        // 7. Save Session
        var session = new UserSession
        {
            SessionId = Guid.NewGuid(),
            UserId = userId,
            RefreshToken = refreshToken,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7), // 7 days expiration
            IsRevoked = false,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            DeviceId = deviceId
        };

        await _sessionRepository.AddAsync(session, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success(new AuthResultResponse(accessToken, refreshToken, userDto, roleDto));
    }

    public async Task<Result<AuthResultResponse>> RefreshAsync(
        RefreshTokenRequest request, 
        string? ipAddress, 
        string? userAgent, 
        string? deviceId, 
        CancellationToken cancellationToken)
    {
        var principal = _tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
        if (principal is null)
        {
            _logger.LogWarning("Token refresh failed: invalid access token.");
            return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidAccessToken", "Invalid access token."));
        }

        var userIdClaim = principal.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub || c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            _logger.LogWarning("Token refresh failed: token claims are invalid.");
            return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidClaims", "Token claims are invalid."));
        }

        var session = await _sessionRepository.GetByRefreshTokenAsync(request.RefreshToken, cancellationToken);
        if (session is null)
        {
            _logger.LogWarning("Token refresh failed: session not found for refresh token.");
            return Result.Failure<AuthResultResponse>(Error.NotFound("Auth.SessionNotFound", "Session not found."));
        }

        // Check if the refresh token belongs to the user from the expired access token
        if (session.UserId != userId)
        {
            _logger.LogWarning("Token refresh failed: session userId {SessionUserId} does not match token userId {TokenUserId}.", session.UserId, userId);
            return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.SessionMismatch", "Session does not match the token user."));
        }

        // RTR Replay Attack Detection: If token is already revoked, revoke all sessions of this user!
        if (session.IsRevoked)
        {
            _logger.LogCritical("Replay attack detected for user {UserId}! Revoking all sessions.", userId);
            await _sessionRepository.RevokeAllSessionsForUserAsync(userId, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.ReplayAttackDetected", "Suspicious refresh attempt. All active sessions have been terminated."));
        }

        if (session.ExpiresAt < DateTime.UtcNow)
        {
            _logger.LogWarning("Token refresh failed: session expired for user {UserId}.", userId);
            return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.SessionExpired", "Session has expired. Please log in again."));
        }

        // Rotate Refresh Token
        var newAccessToken = _tokenService.IssueJwt(
            userId, 
            principal.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Email)?.Value ?? string.Empty, 
            principal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value ?? string.Empty);
        
        var newRefreshToken = _tokenService.GenerateRefreshToken();

        // Update old session
        session.IsRevoked = true;
        session.RevokedAt = DateTime.UtcNow;
        session.ReplacedByToken = newRefreshToken;
        await _sessionRepository.UpdateAsync(session, cancellationToken);

        // Create new session
        var newSession = new UserSession
        {
            SessionId = Guid.NewGuid(),
            UserId = userId,
            RefreshToken = newRefreshToken,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7), // 7 days expiration
            IsRevoked = false,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            DeviceId = deviceId
        };
        await _sessionRepository.AddAsync(newSession, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Construct User and Role details
        UserResponse userDto;
        RoleResponse roleDto;

        if (userId == Guid.Empty)
        {
            // Founder
            userDto = new UserResponse(Guid.Empty, "Founder", _founderSettings.Email, null, null, "ACTIVE");
            roleDto = new RoleResponse(0, "FOUNDER", "Founder");
        }
        else
        {
            var user = await _userRepository.FindByIdAsync(userId, cancellationToken);
            if (user is null)
            {
                return Result.Failure<AuthResultResponse>(Error.NotFound("Auth.UserNotFound", "User not found."));
            }
            userDto = new UserResponse(user.UserId, user.FullName, user.Email, user.Phone, user.ProfilePhotoUri, user.Status);
            roleDto = new RoleResponse(user.Role.RoleId, user.Role.RoleCode, user.Role.RoleName);
        }

        _logger.LogInformation("Tokens rotated successfully for user {UserId}.", userId);
        return Result.Success(new AuthResultResponse(newAccessToken, newRefreshToken, userDto, roleDto));
    }

    public async Task<Result> LogoutAsync(LogoutRequest request, string? accessToken, CancellationToken cancellationToken)
    {
        var session = await _sessionRepository.GetByRefreshTokenAsync(request.RefreshToken, cancellationToken);
        if (session is not null)
        {
            if (!session.IsRevoked)
            {
                session.IsRevoked = true;
                session.RevokedAt = DateTime.UtcNow;
                await _sessionRepository.UpdateAsync(session, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("Session {SessionId} revoked successfully during logout.", session.SessionId);
            }
        }

        // Access Token Blacklisting
        if (!string.IsNullOrEmpty(accessToken))
        {
            var handler = new JwtSecurityTokenHandler();
            if (handler.CanReadToken(accessToken))
            {
                try
                {
                    var jwtToken = handler.ReadJwtToken(accessToken);
                    var jti = jwtToken.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value;
                    var expClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Exp)?.Value;

                    if (!string.IsNullOrEmpty(jti) && !string.IsNullOrEmpty(expClaim))
                    {
                        if (long.TryParse(expClaim, out var expUnix))
                        {
                            var expiryTime = DateTimeOffset.FromUnixTimeSeconds(expUnix).UtcDateTime;
                            var remainingTime = expiryTime - DateTime.UtcNow;
                            if (remainingTime > TimeSpan.Zero)
                            {
                                _memoryCache.Set($"blacklist:{jti}", true, remainingTime);
                                _logger.LogInformation("Access Token (JTI: {Jti}) blacklisted for {RemainingSeconds} seconds.", jti, remainingTime.TotalSeconds);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to blacklist access token during logout.");
                }
            }
        }

        return Result.Success();
    }

    public async Task<Result> RequestPasswordResetAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        // 1. Restrict reset for Founder account
        var founderEmail = _founderSettings.Email;
        if (!string.IsNullOrEmpty(founderEmail) && string.Equals(request.Email, founderEmail, StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Forgot password requested for Founder account: {Email}. Access denied.", request.Email);
            // Return success to prevent email enumeration
            return Result.Success();
        }

        // 2. Find active user
        var user = await _userRepository.FindActiveByEmailAsync(request.Email, cancellationToken);
        if (user == null)
        {
            _logger.LogWarning("Forgot password requested for non-existent email: {Email}", request.Email);
            // Return success to prevent email enumeration
            return Result.Success();
        }

        // 3. Generate random plaintext cryptographic token
        var plainToken = Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N");

        // 4. Hash token using SHA-256
        using var sha256 = SHA256.Create();
        var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainToken));
        var hashedToken = Convert.ToHexString(hashedBytes);

        // 5. Store hashed token & expiration
        user.PasswordResetToken = hashedToken;
        user.ResetTokenExpiry = DateTime.UtcNow.AddMinutes(15); // Valid for 15 minutes

        await _userRepository.UpdateAsync(user, cancellationToken);

        // 6. Send plaintext token via email
        await _emailService.SendPasswordResetEmailAsync(user.Email, plainToken, cancellationToken);

        _logger.LogInformation("Password reset token generated and sent via email for user: {Email}", user.Email);

        return Result.Success();
    }

    public async Task<Result> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        // 1. Restrict reset for Founder account
        var founderEmail = _founderSettings.Email;
        if (!string.IsNullOrEmpty(founderEmail) && string.Equals(request.Email, founderEmail, StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Reset password attempted for Founder account: {Email}. Access denied.", request.Email);
            return Result.Failure(new Error("Auth.FounderResetDenied", "Cannot reset password for Founder account.", ErrorType.Validation));
        }

        // 2. Find active user
        var user = await _userRepository.FindActiveByEmailAsync(request.Email, cancellationToken);
        if (user == null)
        {
            _logger.LogWarning("Reset password attempted for non-existent email: {Email}", request.Email);
            return Result.Failure(new Error("Auth.InvalidCredentials", "Invalid email or token.", ErrorType.Validation));
        }

        // 3. Hash input token using SHA-256 for comparison
        using var sha256 = SHA256.Create();
        var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(request.Token));
        var hashedToken = Convert.ToHexString(hashedBytes);

        // 4. Compare tokens and check expiration
        if (user.PasswordResetToken != hashedToken)
        {
            _logger.LogWarning("Reset password attempted with invalid token for email: {Email}", request.Email);
            return Result.Failure(new Error("Auth.InvalidToken", "Invalid email or token.", ErrorType.Validation));
        }

        if (user.ResetTokenExpiry == null || user.ResetTokenExpiry < DateTime.UtcNow)
        {
            _logger.LogWarning("Reset password attempted with expired token for email: {Email}", request.Email);
            return Result.Failure(new Error("Auth.ExpiredToken", "Token has expired.", ErrorType.Validation));
        }

        // 5. Hash new password using BCrypt
        var hashedPassword = _passwordHashingStrategy.HashPassword(request.NewPassword);
        user.PasswordHash = hashedPassword;

        // 6. Clear reset token details
        user.PasswordResetToken = null;
        user.ResetTokenExpiry = null;

        await _userRepository.UpdateAsync(user, cancellationToken);

        _logger.LogInformation("Password successfully reset for user: {Email}", user.Email);

        return Result.Success();
    }
}
