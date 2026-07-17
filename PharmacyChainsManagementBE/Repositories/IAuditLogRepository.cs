using System;
using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Repositories;

public interface IAuditLogRepository
{
    Task LogExportEventAsync(Guid actorId, string entityName, Guid entityId, string action, string? oldValue, string? newValue, CancellationToken cancellationToken = default);
}
