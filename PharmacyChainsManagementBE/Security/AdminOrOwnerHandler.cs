using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace PharmacyChainsManagementBE.Security;

public class AdminOrOwnerHandler : AuthorizationHandler<AdminOrOwnerRequirement>
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public AdminOrOwnerHandler(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AdminOrOwnerRequirement requirement)
    {
        if (context.User.IsInRole("SUPER_ADMIN"))
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null)
        {
            return Task.CompletedTask;
        }

        var httpContext = _httpContextAccessor.HttpContext;
        var accountIdRouteValue = httpContext?.GetRouteValue("accountId")?.ToString();

        if (accountIdRouteValue != null && accountIdRouteValue.Equals(userIdClaim, System.StringComparison.OrdinalIgnoreCase))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
