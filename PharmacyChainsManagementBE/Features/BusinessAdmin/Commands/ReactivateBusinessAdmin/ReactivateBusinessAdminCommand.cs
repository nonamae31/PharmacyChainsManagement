using System;
using MediatR;
using PharmacyChainsManagementBE.Common;

namespace PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.ReactivateBusinessAdmin;

public record ReactivateBusinessAdminCommand(Guid AdminId, string? IpAddress) : IRequest<ApiResponse<object>>;
