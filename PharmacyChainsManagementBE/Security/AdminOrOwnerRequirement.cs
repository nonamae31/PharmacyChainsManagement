using Microsoft.AspNetCore.Authorization;

namespace PharmacyChainsManagementBE.Security;

public class AdminOrOwnerRequirement : IAuthorizationRequirement { }
