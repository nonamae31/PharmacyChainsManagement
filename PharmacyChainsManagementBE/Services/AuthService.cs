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
    private readonly IAuditLogService _auditLogService;
    private readonly IEmailAlertQueue _emailAlertQueue;

    public AuthService(
        IUserRepository userRepository,
        ISessionRepository sessionRepository,
        ITokenService tokenService,
        IPasswordHashingStrategy passwordHashingStrategy,
        IEmailService emailService,
        IUnitOfWork unitOfWork,
        IOptions<FounderSettings> founderSettings,
        IMemoryCache memoryCache,
        ILogger<AuthService> logger,
        IAuditLogService auditLogService,
        IEmailAlertQueue emailAlertQueue)
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
        _auditLogService = auditLogService;
        _emailAlertQueue = emailAlertQueue;
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

        if (!string.IsNullOrEmpty(_founderSettings.Email) && request.Email.Equals(_founderSettings.Email, StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogInformation("Founder login attempt for email: {Email}", request.Email);
            
            bool isPasswordValid = request.Password == _founderSettings.Password;
            if (!isPasswordValid)
            {
                _logger.LogWarning("Founder login failed: Invalid credentials for email: {Email}", request.Email);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

            var founderUser = await _userRepository.FindActiveByEmailAsync(request.Email, cancellationToken)
                ?? await _userRepository.FindByEmailAsync(request.Email, cancellationToken);

            if (founderUser == null)
            {
                var role = await _userRepository.GetRoleByCodeAsync("BUSINESS_ADMIN", cancellationToken);
                founderUser = new User
                {
                    UserId = Guid.NewGuid(),
                    FullName = "Founder",
                    Email = request.Email,
                    PasswordHash = _passwordHashingStrategy.HashPassword(request.Password),
                    Status = "ACTIVE",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    RoleId = role?.RoleId ?? 1 // Fallback if no role found
                };
                await _userRepository.AddAsync(founderUser, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);
            }

            userId = founderUser.UserId;
            userDto = new UserResponse(userId, founderUser.FullName, founderUser.Email, founderUser.Phone, founderUser.ProfilePhotoUri, founderUser.Status);
            roleDto = new RoleResponse(0, "Founder", "Founder");
            _logger.LogInformation("Founder logged in successfully from IP: {IpAddress}. Assigned UserId: {UserId}", ipAddress, userId);
        }
        else
        {
            var user = await _userRepository.FindActiveByEmailAsync(request.Email, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("Login failed: User not found or inactive for email: {Email}", request.Email);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

            if (user.LockoutEnd.HasValue && user.LockoutEnd.Value > DateTime.UtcNow)
            {
                var timeLeft = user.LockoutEnd.Value - DateTime.UtcNow;
                _logger.LogWarning("Login failed: Account locked for email: {Email}. Lockout ends at {LockoutEnd}", request.Email, user.LockoutEnd.Value);
                return Result.Failure<AuthResultResponse>(Error.Validation(
                    "Auth.AccountLocked", 
                    $"Account is temporarily locked. Please try again in {Math.Ceiling(timeLeft.TotalMinutes)} minutes."));
            }

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
                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                    
                    return Result.Failure<AuthResultResponse>(Error.Validation(
                        "Auth.AccountLocked", 
                        "Account is temporarily locked for 15 minutes due to multiple failed login attempts."));
                }

                await _userRepository.UpdateAsync(user, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.InvalidCredentials", "Invalid email or password."));
            }

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

            var lastSession = await _sessionRepository.GetLastSessionByUserIdAsync(userId, cancellationToken);
            if (lastSession != null && lastSession.IpAddress != ipAddress)
            {
                _logger.LogWarning("Suspicious login detected for user {UserId} from new IP {IpAddress}.", userId, ipAddress);
                await _emailAlertQueue.EnqueueEmailAsync(new EmailMessage(userDto.Email, "Suspicious Login Alert", $"A login was detected from a new IP Address: {ipAddress}. If this was not you, please secure your account."), cancellationToken);
            }
        }

        await _auditLogService.LogAsync("UserLogin", $"User logged in successfully from IP: {ipAddress}", userId.ToString(), ipAddress, cancellationToken);

        var accessToken = _tokenService.IssueJwt(userId, userDto.Email, roleDto.RoleCode);
        var refreshToken = _tokenService.GenerateRefreshToken();

        if (userId != Guid.Empty)
        {
            var session = new UserSession
            {
                SessionId = Guid.NewGuid(),
                UserId = userId,
                RefreshToken = refreshToken,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMonths(1),
                IsRevoked = false,
                IpAddress = ipAddress,
                UserAgent = userAgent,
                DeviceId = deviceId
            };

            await _sessionRepository.AddAsync(session, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }

        return Result.Success(new AuthResultResponse(accessToken, refreshToken, userDto, roleDto));
    }

    public async Task<Result<AuthResultResponse>> GoogleLoginAsync(
        GoogleLoginRequest request, string? ipAddress, string? userAgent, string? deviceId, CancellationToken cancellationToken)
    {
        var handler = new JwtSecurityTokenHandler();
        if (!handler.CanReadToken(request.IdToken))
        {
            return Result.Failure<AuthResultResponse>(Error.Validation("Auth.InvalidToken", "Invalid Firebase token."));
        }

        var jwtToken = handler.ReadJwtToken(request.IdToken);
        var email = jwtToken.Claims.FirstOrDefault(c => c.Type == "email")?.Value;

        if (string.IsNullOrEmpty(email))
        {
            return Result.Failure<AuthResultResponse>(Error.Validation("Auth.EmailMissing", "Token does not contain an email."));
        }

        var cacheKey = $"UserProfile_{email}";
        if (!_memoryCache.TryGetValue(cacheKey, out (UserResponse userDto, RoleResponse roleDto, Guid userId) cachedProfile))
        {
            Guid userId;
            UserResponse userDto;
            RoleResponse roleDto;

            if (!string.IsNullOrEmpty(_founderSettings.Email) && email.Equals(_founderSettings.Email, StringComparison.OrdinalIgnoreCase))
            {
                var founderUser = await _userRepository.FindActiveByEmailAsync(email, cancellationToken)
                    ?? await _userRepository.FindByEmailAsync(email, cancellationToken);

                var role = await _userRepository.GetRoleByCodeAsync("FOUNDER", cancellationToken);
                short founderRoleId = role?.RoleId ?? 5;

                if (founderUser == null)
                {
                    founderUser = new User
                    {
                        UserId = Guid.NewGuid(),
                        FullName = "Founder",
                        Email = email,
                        PasswordHash = _passwordHashingStrategy.HashPassword(_founderSettings.Password ?? "Founder@1234"),
                        Status = "ACTIVE",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                        RoleId = founderRoleId
                    };
                    await _userRepository.AddAsync(founderUser, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                }
                else if (founderUser.RoleId != founderRoleId)
                {
                    founderUser.RoleId = founderRoleId;
                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                }

                userId = founderUser.UserId;
                userDto = new UserResponse(userId, founderUser.FullName, founderUser.Email, founderUser.Phone, founderUser.ProfilePhotoUri, founderUser.Status);
                roleDto = new RoleResponse(0, "Founder", "Founder");
            }
            else
            {
                var user = await _userRepository.FindActiveByEmailAsync(email, cancellationToken);
                if (user == null)
                {
                    return Result.Failure<AuthResultResponse>(Error.Unauthorized("Auth.UserNotFound", "Tài khoản không tồn tại trong hệ thống. Vui lòng đăng ký."));
                }

                if (user.LockoutEnd.HasValue && user.LockoutEnd.Value > DateTime.UtcNow)
                {
                    var timeLeft = user.LockoutEnd.Value - DateTime.UtcNow;
                    return Result.Failure<AuthResultResponse>(Error.Validation("Auth.AccountLocked", $"Account is temporarily locked. Please try again in {Math.Ceiling(timeLeft.TotalMinutes)} minutes."));
                }

                user.AccessFailedCount = 0;
                user.LockoutEnd = null;
                await _userRepository.UpdateAsync(user, cancellationToken);

                var userRoleCode = user.Role?.RoleCode ?? "USER";
                var userRoleName = user.Role?.RoleName ?? "User";
                var userRoleId = user.Role?.RoleId ?? 0;

                userId = user.UserId;
                userDto = new UserResponse(user.UserId, user.FullName, user.Email, user.Phone, user.ProfilePhotoUri, user.Status);
                roleDto = new RoleResponse(userRoleId, userRoleCode, userRoleName);
            }
            
            cachedProfile = (userDto, roleDto, userId);

            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(10));
            _memoryCache.Set(cacheKey, cachedProfile, cacheEntryOptions);
        }

        await _auditLogService.LogAsync("UserLogin", $"User logged in successfully via Google from IP: {ipAddress}", cachedProfile.userId.ToString(), ipAddress, cancellationToken);

        var accessToken = _tokenService.IssueJwt(cachedProfile.userId, cachedProfile.userDto.Email, cachedProfile.roleDto.RoleCode);
        var refreshToken = _tokenService.GenerateRefreshToken();

        var session = new UserSession
        {
            SessionId = Guid.NewGuid(),
            UserId = cachedProfile.userId,
            RefreshToken = refreshToken,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddMonths(1),
            IsRevoked = false,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            DeviceId = deviceId
        };

        await _sessionRepository.AddAsync(session, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success(new AuthResultResponse(accessToken, refreshToken, cachedProfile.userDto, cachedProfile.roleDto));
    }

    public async Task<Result<AuthResultResponse>> RefreshAsync(
        RefreshTokenRequest request, string? ipAddress, string? userAgent, string? deviceId, CancellationToken cancellationToken)
    {
        return Result.Failure<AuthResultResponse>(Error.NotFound("NotImplemented", "In Draft mode."));
    }

    public async Task<Result> LogoutAsync(LogoutRequest request, string? accessToken, CancellationToken cancellationToken)
    {
        return Result.Success();
    }

    public async Task<Result> RequestPasswordResetAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        return Result.Success();
    }

    public async Task<Result> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        return Result.Success();
    }
}
