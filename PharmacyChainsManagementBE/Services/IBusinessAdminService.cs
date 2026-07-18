using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs.Responses;

namespace PharmacyChainsManagementBE.Services;

public interface IBusinessAdminService
{
    Task<ApiResponse<BusinessAdminDetailResponse>> GetBusinessAdminAsync(Guid accountId, CancellationToken cancellationToken = default);
    Task<ApiResponse<System.Collections.Generic.List<BusinessAdminDetailResponse>>> GetBusinessAdminsAsync(CancellationToken cancellationToken = default);
    Task<ApiResponse<BusinessAdminDetailResponse>> CreateBusinessAdminAsync(DTOs.CreateBusinessAdminRequest request, string? ipAddress, CancellationToken cancellationToken = default);
    Task<ApiResponse<object>> VerifyAndDeactivateAsync(Guid adminId, string reason, string? ipAddress, CancellationToken cancellationToken = default);
    Task<ApiResponse<object>> GetBusinessAdminStatusAsync(Guid adminId, CancellationToken cancellationToken = default);
    Task<ApiResponse<BusinessAdminDetailResponse>> UpdateBusinessAdminAsync(Guid accountId, DTOs.UpdateBusinessAdminRequest request, Guid currentUserId, string? currentUserRole, string? ipAddress, CancellationToken cancellationToken = default);
}
