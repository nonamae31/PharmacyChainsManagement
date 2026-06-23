using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class SessionRepository : ISessionRepository
{
    private readonly PharmacyDbContext _context;

    public SessionRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task<UserSession?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
    {
        return await _context.Set<UserSession>()
            .FirstOrDefaultAsync(s => s.RefreshToken == refreshToken, cancellationToken);
    }

    public async Task AddAsync(UserSession session, CancellationToken cancellationToken)
    {
        await _context.Set<UserSession>().AddAsync(session, cancellationToken);
    }

    public async Task UpdateAsync(UserSession session, CancellationToken cancellationToken)
    {
        _context.Set<UserSession>().Update(session);
        await Task.CompletedTask;
    }

    public async Task RevokeAllSessionsForUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var activeSessions = await _context.Set<UserSession>()
            .Where(s => s.UserId == userId && !s.IsRevoked)
            .ToListAsync(cancellationToken);

        foreach (var session in activeSessions)
        {
            session.IsRevoked = true;
            session.RevokedAt = DateTime.UtcNow;
        }

        _context.Set<UserSession>().UpdateRange(activeSessions);
    }
}
