using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Features.Finance;
using PharmacyChainsManagementBE.Services;
using PharmacyChainsManagementBE.DTOs.Finance;

namespace PharmacyChainsManagementBE.Controllers;

[Route("api/finance")]
[ApiController]
[Authorize(Roles = "Founder,Admin")]
public class FinanceController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IFinancialReportService _financialReportService;

    public FinanceController(IMediator mediator, IFinancialReportService financialReportService)
    {
        _mediator = mediator;
        _financialReportService = financialReportService;
    }

    [HttpGet("cash-flow")]
    [EnableRateLimiting("CashFlowReportPolicy")]
    public async Task<IActionResult> GetCashFlow([FromQuery] DateOnly startDate, [FromQuery] DateOnly endDate, [FromQuery] Guid? branchId)
    {
        if (startDate > endDate)
        {
            return BadRequest(new ProblemDetails
            {
                Status = 400,
                Title = "Invalid Date Range",
                Detail = "startDate must be less than or equal to endDate."
            });
        }
        
        var query = new GetCashFlowQuery
        {
            StartDate = startDate,
            EndDate = endDate,
            BranchId = branchId
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpPost("export")]
    [EnableRateLimiting("export_policy")]
    public async Task<IActionResult> ExportFinancialReport([FromBody] ExportCriteriaDTO criteria)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        try
        {
            var (fileStream, contentType, fileName) = await _financialReportService.GenerateReportAsync(criteria, userId);
            return File(fileStream, contentType, fileName);
        }
        catch (PharmacyChainsManagementBE.Common.Exceptions.DataNotFoundException)
        {
            return NotFound("No Data Found");
        }
        catch (Exception ex)
        {
            return StatusCode(500, ex.ToString());
        }
    }
}
