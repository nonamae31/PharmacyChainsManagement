using System;
using MediatR;

namespace PharmacyChainsManagementBE.Events;

public class BusinessAdminDeactivated : INotification
{
    public Guid AdminId { get; }
    public string Reason { get; }
    public DateTime DeactivatedAt { get; }

    public BusinessAdminDeactivated(Guid adminId, string reason, DateTime deactivatedAt)
    {
        AdminId = adminId;
        Reason = reason;
        DeactivatedAt = deactivatedAt;
    }
}
