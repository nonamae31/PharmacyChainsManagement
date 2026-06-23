using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
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

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResultResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = HttpContext.Request.Headers.UserAgent.FirstOrDefault();
        var deviceId = HttpContext.Request.Headers["X-Device-ID"].FirstOrDefault();

        var result = await _authService.LoginAsync(request, ipAddress, userAgent, deviceId, cancellationToken);

        if (result.IsFailure)
        {
            return ToProblemDetails(result);
        }

        var authResult = result.Value;

        // Support both Flutter mobile clients and Web clients securely
        var clientType = Request.Headers["X-Client-Type"].ToString();
        var userAgentHeader = Request.Headers["User-Agent"].ToString();
        bool isMobile = clientType.Equals("Mobile", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Flutter", StringComparison.OrdinalIgnoreCase) ||
                        userAgentHeader.Contains("Dart", StringComparison.OrdinalIgnoreCase);

        if (!isMobile)
        {
            // Web Client: Store Refresh Token in HttpOnly cookie to mitigate XSS attacks
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7),
                Path = "/api/v1/auth"
            };
            Response.Cookies.Append("refreshToken", authResult.RefreshToken, cookieOptions);

            // Strip the Refresh Token from the response body for web clients
            authResult = authResult with { RefreshToken = string.Empty };
        }

        return Ok(authResult);
    }

    [Authorize]
    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var authHeader = HttpContext.Request.Headers.Authorization.FirstOrDefault();
        string? accessToken = null;
        if (authHeader is not null && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            accessToken = authHeader["Bearer ".Length..].Trim();
        }

        // Support cookies for Web clients
        var refreshToken = request.RefreshToken;
        if (string.IsNullOrEmpty(refreshToken))
        {
            refreshToken = Request.Cookies["refreshToken"] ?? string.Empty;
        }

        var adjustedRequest = new LogoutRequest(refreshToken);
        var result = await _authService.LogoutAsync(adjustedRequest, accessToken, cancellationToken);

        if (result.IsFailure)
        {
            return ToProblemDetails(result);
        }

        // Clear the refresh token cookie if any
        Response.Cookies.Delete("refreshToken", new CookieOptions
        {
            Path = "/api/v1/auth"
        });

        return Ok(new { Message = "Logged out successfully." });
    }

    [HttpPost("refresh")]
    [ProducesResponseType(typeof(AuthResultResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status412PreconditionFailed)]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Support cookies for Web clients
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
            return ToProblemDetails(result);
        }

        var authResult = result.Value;

        // Support both Flutter mobile clients and Web clients securely
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

        return Ok(authResult);
    }

    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _authService.RequestPasswordResetAsync(request, cancellationToken);
        
        return result.IsSuccess 
            ? Ok(new { Message = "If the email exists in our system, a password reset link has been sent." }) 
            : ToProblemDetails(result);
    }

    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _authService.ResetPasswordAsync(request, cancellationToken);
        
        return result.IsSuccess 
            ? Ok(new { Message = "Your password has been successfully reset." }) 
            : ToProblemDetails(result);
    }
}
