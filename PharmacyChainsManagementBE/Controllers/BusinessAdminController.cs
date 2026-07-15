using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs.Responses;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[Route("api/v1/business-admin")]
[ApiController]
public class BusinessAdminController : ControllerBase
{
    private readonly IBusinessAdminService _businessAdminService;

    public BusinessAdminController(IBusinessAdminService businessAdminService)
    {
        _businessAdminService = businessAdminService;
    }

    /// <summary>
    /// Gets business admin details by ID.
    /// </summary>
    /// <param name="accountId">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin details.</returns>
    [HttpGet("{accountId}")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("GetAdminPolicy")]
    [ResponseCache(Duration = 60, Location = ResponseCacheLocation.Client)]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBusinessAdmin(Guid accountId, CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminAsync(accountId, cancellationToken);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }
}
