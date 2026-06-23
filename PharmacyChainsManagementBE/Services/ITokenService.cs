using System;
using System.Security.Claims;

namespace PharmacyChainsManagementBE.Services;

public interface ITokenService
{
    string IssueJwt(Guid userId, string email, string roleCode);
    string GenerateAccessToken(Guid userId, string email, string roleCode);
    string GenerateRefreshToken();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
}
