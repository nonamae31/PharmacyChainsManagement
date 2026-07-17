using System;
using MediatR;
using PharmacyChainsManagementBE.Common;

namespace PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.SoftDeleteBusinessAdmin;

public record SoftDeleteBusinessAdminCommand(Guid AdminId, string? IpAddress) : IRequest<ApiResponse<object>>;
