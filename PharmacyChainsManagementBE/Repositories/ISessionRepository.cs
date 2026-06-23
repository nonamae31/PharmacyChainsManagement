using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public interface ISessionRepository
{
    Task<UserSession?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken);
    Task AddAsync(UserSession session, CancellationToken cancellationToken);
    Task UpdateAsync(UserSession session, CancellationToken cancellationToken);
    Task RevokeAllSessionsForUserAsync(Guid userId, CancellationToken cancellationToken);
}
