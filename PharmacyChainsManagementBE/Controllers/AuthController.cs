using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : BaseApiController
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [EnableRateLimiting("LoginPolicy")]
    [HttpPost("login")]
    [ProducesResponseType(typeof(ApiResponse<AuthResultResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = HttpContext.Request.Headers.UserAgent.FirstOrDefault();
        var deviceId = HttpContext.Request.Headers["X-Device-ID"].FirstOrDefault();

        var result = await _authService.LoginAsync(request, ipAddress, userAgent, deviceId, cancellationToken);

        if (result.IsFailure)
        {
            return Unauthorized(ApiResponse<object>.ErrorResponse(result.Error.Message));
        }

        var authResult = result.Value;

        var clientType = Request.Headers["X-Client-Type"].ToString();
        var userAgentHeader = Request.Headers["User-Agent"].ToString();
        bool isMobile = clientType.Equals("Mobile", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Flutter", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Dart", StringComparison.OrdinalIgnoreCase);

        if (!isMobile)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7),
                Path = "/api/v1/auth"
            };
            Response.Cookies.Append("refreshToken", authResult.RefreshToken, cookieOptions);
            authResult = authResult with { RefreshToken = string.Empty };
        }

        return Ok(ApiResponse<AuthResultResponse>.Ok(authResult, "Login successful"));
    }

    [Authorize]
    [HttpPost("logout")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var authHeader = HttpContext.Request.Headers.Authorization.FirstOrDefault();
        string? accessToken = null;
        if (authHeader is not null && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            accessToken = authHeader["Bearer ".Length..].Trim();
        }

        var refreshToken = request.RefreshToken;
        if (string.IsNullOrEmpty(refreshToken))
        {
            refreshToken = Request.Cookies["refreshToken"] ?? string.Empty;
        }

        var adjustedRequest = new LogoutRequest(refreshToken);
        var result = await _authService.LogoutAsync(adjustedRequest, accessToken, cancellationToken);

        if (result.IsFailure)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        }

        Response.Cookies.Delete("refreshToken", new CookieOptions
        {
            Path = "/api/v1/auth"
        });

        return Ok(ApiResponse<object>.Ok(null, "Logged out successfully."));
    }

    [HttpPost("refresh")]
    [ProducesResponseType(typeof(ApiResponse<AuthResultResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status412PreconditionFailed)]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var refreshToken = request.RefreshToken;
        if (string.IsNullOrEmpty(refreshToken))
        {
            refreshToken = Request.Cookies["refreshToken"] ?? string.Empty;
        }

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = HttpContext.Request.Headers.UserAgent.FirstOrDefault();
        var deviceId = HttpContext.Request.Headers["X-Device-ID"].FirstOrDefault();

        var adjustedRequest = new RefreshTokenRequest(request.AccessToken, refreshToken);
        var result = await _authService.RefreshAsync(adjustedRequest, ipAddress, userAgent, deviceId, cancellationToken);

        if (result.IsFailure)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        }

        var authResult = result.Value;

        var clientType = Request.Headers["X-Client-Type"].ToString();
        var userAgentHeader = Request.Headers["User-Agent"].ToString();
        bool isMobile = clientType.Equals("Mobile", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Flutter", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Dart", StringComparison.OrdinalIgnoreCase);

        if (!isMobile)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7),
                Path = "/api/v1/auth"
            };
            Response.Cookies.Append("refreshToken", authResult.RefreshToken, cookieOptions);
            authResult = authResult with { RefreshToken = string.Empty };
        }

        return Ok(ApiResponse<AuthResultResponse>.Ok(authResult, "Token refreshed successfully"));
    }

    [HttpPost("forgot-password")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var result = await _authService.RequestPasswordResetAsync(request, cancellationToken);
        
        return result.IsSuccess 
            ? Ok(ApiResponse<object>.Ok(null, "If the email exists in our system, a password reset link has been sent.")) 
            : BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
    }

    [HttpPost("reset-password")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var result = await _authService.ResetPasswordAsync(request, cancellationToken);
        
        return result.IsSuccess 
            ? Ok(ApiResponse<object>.Ok(null, "Your password has been successfully reset.")) 
            : BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
    }

    [EnableRateLimiting("LoginPolicy")]
    [HttpPost("google-login")]
    [ProducesResponseType(typeof(ApiResponse<AuthResultResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Validation failed", ModelState));
        }

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = HttpContext.Request.Headers.UserAgent.FirstOrDefault();
        var deviceId = HttpContext.Request.Headers["X-Device-ID"].FirstOrDefault();

        var result = await _authService.GoogleLoginAsync(request, ipAddress, userAgent, deviceId, cancellationToken);

        if (result.IsFailure)
        {
            return Unauthorized(ApiResponse<object>.ErrorResponse(result.Error.Message));
        }

        var authResult = result.Value;

        var clientType = Request.Headers["X-Client-Type"].ToString();
        var userAgentHeader = Request.Headers["User-Agent"].ToString();
        bool isMobile = clientType.Equals("Mobile", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Flutter", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Dart", StringComparison.OrdinalIgnoreCase);

        if (!isMobile)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7),
                Path = "/api/v1/auth"
            };
            Response.Cookies.Append("refreshToken", authResult.RefreshToken, cookieOptions);
            authResult = authResult with { RefreshToken = string.Empty };
        }

        return Ok(ApiResponse<AuthResultResponse>.Ok(authResult, "Google login successful"));
    }
}
