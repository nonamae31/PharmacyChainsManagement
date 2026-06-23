using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;

namespace PharmacyChainsManagementBE.Services;

public interface IAuthService
{
    Task<Result<AuthResultResponse>> LoginAsync(LoginRequest request, string? ipAddress, string? userAgent, string? deviceId, CancellationToken cancellationToken);
    Task<Result> LogoutAsync(LogoutRequest request, string? accessToken, CancellationToken cancellationToken);
    Task<Result<AuthResultResponse>> RefreshAsync(RefreshTokenRequest request, string? ipAddress, string? userAgent, string? deviceId, CancellationToken cancellationToken);
    Task<Result> RequestPasswordResetAsync(ForgotPasswordRequest request, CancellationToken cancellationToken);
    Task<Result> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken);
}
