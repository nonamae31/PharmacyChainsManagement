using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PharmacyChainsManagementBE.Services;

public class AuditLogService : IAuditLogService
{
    private readonly ILogger<AuditLogService> _logger;

    public AuditLogService(ILogger<AuditLogService> logger)
    {
        _logger = logger;
    }

    public Task LogAsync(string action, string details, string? userId, string? ipAddress, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("AuditLog - Action: {Action}, Details: {Details}, UserId: {UserId}, IpAddress: {IpAddress}", 
            action, details, userId, ipAddress);
        return Task.CompletedTask;
    }
}
