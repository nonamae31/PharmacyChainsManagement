using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services;

public interface IAuditLogService
{
    Task LogAsync(string action, string details, string? userId, string? ipAddress, CancellationToken cancellationToken = default);
}
