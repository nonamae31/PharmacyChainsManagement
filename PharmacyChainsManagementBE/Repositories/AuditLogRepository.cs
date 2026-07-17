using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class AuditLogRepository : IAuditLogRepository
{
    private readonly PharmacyDbContext _context;

    public AuditLogRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task LogExportEventAsync(Guid actorId, string entityName, Guid entityId, string action, string? oldValue, string? newValue, CancellationToken cancellationToken = default)
    {
        var auditLog = new AuditLog
        {
            AuditId = Guid.NewGuid(),
            ActorId = actorId,
            EntityName = entityName,
            EntityId = entityId,
            Action = action,
            OldValue = oldValue,
            NewValue = newValue,
            CreatedAt = DateTime.UtcNow
        };

        await _context.AuditLogs.AddAsync(auditLog, cancellationToken);
    }
}
