using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class UserRepository : IUserRepository
{
    private readonly PharmacyDbContext _context;

    public UserRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task<User?> FindActiveByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.Email == email && u.Status == "ACTIVE", cancellationToken);
    }

    public async Task<User?> FindByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    }

    public async Task<User?> FindByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.UserId == id, cancellationToken);
    }

    public Task UpdateAsync(User user, CancellationToken cancellationToken = default)
    {
        _context.Users.Update(user);
        return Task.CompletedTask;
    }

    public async Task AddAsync(User user, CancellationToken cancellationToken = default)
    {
        await _context.Users.AddAsync(user, cancellationToken);
    }

    public async Task<Role?> GetRoleByCodeAsync(string roleCode, CancellationToken cancellationToken = default)
    {
        return await _context.Roles.FirstOrDefaultAsync(r => r.RoleCode == roleCode, cancellationToken);
    }

    public async Task<User?> GetBusinessAdminByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.UserId == id && u.Role.RoleCode == "BUSINESS_ADMIN", cancellationToken);
    }

    public async Task<System.Collections.Generic.IEnumerable<User>> GetUsersByRoleCodeAsync(string roleCode, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .Where(u => u.Role.RoleCode == roleCode)
            .OrderByDescending(u => u.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public void Remove(User user)
    {
        _context.Users.Remove(user);
    }
}
