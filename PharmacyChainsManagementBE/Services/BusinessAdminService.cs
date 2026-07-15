using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs.Responses;
using PharmacyChainsManagementBE.Repositories;

namespace PharmacyChainsManagementBE.Services;

public class BusinessAdminService : IBusinessAdminService
{
    private readonly IUserRepository _userRepository;

    public BusinessAdminService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<ApiResponse<BusinessAdminDetailResponse>> GetBusinessAdminAsync(Guid accountId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetBusinessAdminByIdAsync(accountId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Business admin not found.");
        }

        var response = new BusinessAdminDetailResponse
        {
            Id = user.UserId,
            Name = user.FullName,
            Email = user.Email,
            Status = user.Status
        };

        return ApiResponse<BusinessAdminDetailResponse>.Ok(response);
    }
}
