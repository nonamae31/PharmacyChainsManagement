using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public interface IUserRepository
{
    Task<User?> FindActiveByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> FindByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> FindByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task UpdateAsync(User user, CancellationToken cancellationToken = default);
    Task AddAsync(User user, CancellationToken cancellationToken = default);
    Task<Role?> GetRoleByCodeAsync(string roleCode, CancellationToken cancellationToken = default);
    Task<User?> GetBusinessAdminByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<User>> GetUsersByRoleCodeAsync(string roleCode, CancellationToken cancellationToken = default);
}
