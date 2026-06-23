using System;
using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs;

public record LoginRequest(
    [Required][EmailAddress] string Email, 
    [Required] string Password
);

public record LogoutRequest(
    [Required] string RefreshToken
);

public record RefreshTokenRequest(
    [Required] string AccessToken,
    [Required] string RefreshToken
);

public record ForgotPasswordRequest(
    [Required][EmailAddress] string Email
);

public record ForgotPasswordRequestDTO(
    [Required][EmailAddress] string Email
) : ForgotPasswordRequest(Email);

public record ResetPasswordRequest(
    [Required][EmailAddress] string Email,
    [Required] string Token,
    [Required][MinLength(8)] string NewPassword
);

public record ResetPasswordRequestDTO(
    [Required][EmailAddress] string Email,
    [Required] string Token,
    [Required][MinLength(8)] string NewPassword
) : ResetPasswordRequest(Email, Token, NewPassword);

public record AuthResultResponse(
    string AccessToken, 
    string RefreshToken, 
    UserResponse User, 
    RoleResponse Role
);

public record UserResponse(
    Guid UserId, 
    string FullName, 
    string Email, 
    string? Phone, 
    string? ProfilePhotoUri, 
    string Status
);

public record RoleResponse(
    short RoleId, 
    string RoleCode, 
    string RoleName
);
