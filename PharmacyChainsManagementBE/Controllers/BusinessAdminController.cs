using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.DTOs.Responses;
using PharmacyChainsManagementBE.Filters;
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

    /// <summary>
    /// Gets a list of all business admins.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of business admins.</returns>
    [HttpGet]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("GetAdminPolicy")]
    [ProducesResponseType(typeof(ApiResponse<System.Collections.Generic.List<BusinessAdminDetailResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetBusinessAdmins(CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminsAsync(cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Creates a new business admin account.
    /// </summary>
    /// <param name="request">The create request data.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin details.</returns>
    [HttpPost]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("CreateAdminPolicy")]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status409Conflict)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateBusinessAdmin([FromBody] DTOs.CreateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.CreateBusinessAdminAsync(request, ipAddress, cancellationToken);
        if (!result.Success && result.Message == "Email đã tồn tại trong hệ thống.")
        {
            return Conflict(result);
        }
        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Gets business admin status by ID.
    /// </summary>
    /// <param name="adminId">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin status.</returns>
    [HttpGet("{adminId}/status")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBusinessAdminStatus(Guid adminId, CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminStatusAsync(adminId, cancellationToken);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Deactivates a business admin account.
    /// </summary>
    /// <param name="adminId">The account ID.</param>
    /// <param name="request">The deactivate request data containing reason.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpPost("{adminId}/deactivate")]
    [Authorize(Roles = "Founder")]
    [IdempotencyKey]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> DeactivateBusinessAdmin(Guid adminId, [FromBody] DeactivateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.VerifyAndDeactivateAsync(adminId, request.Reason, ipAddress, cancellationToken);
        if (!result.Success)
        {
            if (result.Message == "Business Admin không tồn tại.")
                return NotFound(result);
            return BadRequest(result);
        }

        return Ok(result);
    }
    /// <summary>
    /// Updates business admin profile.
    /// </summary>
    /// <param name="accountId">The account ID.</param>
    /// <param name="request">The update request data.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpPut("{accountId}")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("ProfileUpdatePolicy")]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> UpdateBusinessAdmin(Guid accountId, [FromBody] UpdateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var currentUserIdClaim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var currentUserRoleClaim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Role)?.Value;

        Guid currentUserId = Guid.Empty;
        if (currentUserIdClaim != null) Guid.TryParse(currentUserIdClaim, out currentUserId);

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.UpdateBusinessAdminAsync(accountId, request, currentUserId, currentUserRoleClaim, ipAddress, cancellationToken);

        if (!result.Success)
        {
            if (result.Message.Contains("không tồn tại"))
                return NotFound(result);
            if (result.Message.Contains("tồn tại trong hệ thống"))
                return Conflict(result);
            if (result.Message.Contains("quyền") || result.Message.Contains("truy cập"))
                return StatusCode(403, result);
            return BadRequest(result);
        }

        return Ok(result);
    }
}
