using System;

namespace PharmacyChainsManagementBE.Services
{
    public interface ICurrentUserService
    {
        Guid? UserId { get; }
        string? Role { get; }
    }
}
