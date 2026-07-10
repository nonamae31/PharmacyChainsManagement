using System;

namespace PharmacyChainsManagementBE.DTOs;

public record LoginRequest(string Email, string Password);
public record LogoutRequest(string RefreshToken);
public record RefreshTokenRequest(string AccessToken, string RefreshToken);
public record ForgotPasswordRequest(string Email);
public record ResetPasswordRequest(string Email, string Token, string NewPassword);
public record GoogleLoginRequest(string IdToken);

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
