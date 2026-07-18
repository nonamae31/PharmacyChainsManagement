using System.Threading;
using System.Threading.Tasks;
using MediatR;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Events;

public class AuditLogEventHandler : INotificationHandler<AuditLogEvent>
{
    private readonly IAuditLogService _auditLogService;

    public AuditLogEventHandler(IAuditLogService auditLogService)
    {
        _auditLogService = auditLogService;
    }

    public async Task Handle(AuditLogEvent notification, CancellationToken cancellationToken)
    {
        await _auditLogService.LogAsync(
            notification.Action,
            notification.Details,
            notification.TargetId,
            notification.IpAddress,
            cancellationToken);
    }
}
