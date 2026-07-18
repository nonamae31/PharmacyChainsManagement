using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReportsController : ControllerBase
{
    private readonly IRevenueReportService _revenueReportService;

    public ReportsController(IRevenueReportService revenueReportService)
    {
        _revenueReportService = revenueReportService;
    }

    [HttpPost("revenue")]
    [Authorize(Roles = "Founder,SuperAdmin,BusinessAdmin,BranchManager")] // Bảo mật phân quyền
    public async Task<IActionResult> GenerateRevenueReport([FromBody] RevenueReportRequestDto request)
    {
        // FluentValidation sẽ tự động validate ModelState, nhưng thêm check cẩn thận
        if (!ModelState.IsValid)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ.", ModelState));
        }

        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(ApiResponse<object>.ErrorResponse("Token không hợp lệ."));
        }

        try
        {
            var responseDto = await _revenueReportService.GenerateRevenueReportAsync(request, userId);
            // Chuẩn hóa ApiResponse
            return Ok(ApiResponse<RevenueReportResponseDto>.Ok(responseDto, "Tạo báo cáo doanh thu thành công."));
        }
        catch (Exception ex)
        {
            // Defensive programming: không leak exception ra ngoài cho client
            return StatusCode(500, ApiResponse<object>.ErrorResponse("Đã xảy ra lỗi khi tạo báo cáo.", ex.Message));
        }
    }
}
