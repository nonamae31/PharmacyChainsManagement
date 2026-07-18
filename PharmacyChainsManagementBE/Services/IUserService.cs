using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.Users;

namespace PharmacyChainsManagementBE.Services
{
    public interface IUserService
    {
        Task<bool> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken = default);
        Task<UserProfileDto?> GetProfileAsync(Guid userId, CancellationToken cancellationToken = default);
    }
}
