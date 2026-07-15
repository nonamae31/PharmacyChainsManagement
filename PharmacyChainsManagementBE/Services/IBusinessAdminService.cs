using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs.Responses;

namespace PharmacyChainsManagementBE.Services;

public interface IBusinessAdminService
{
    Task<ApiResponse<BusinessAdminDetailResponse>> GetBusinessAdminAsync(Guid accountId, CancellationToken cancellationToken = default);
}
