using System;
using MediatR;

namespace PharmacyChainsManagementBE.Events;

public record AuditLogEvent(
    string Action,
    string Details,
    string TargetId,
    string? IpAddress) : INotification;
