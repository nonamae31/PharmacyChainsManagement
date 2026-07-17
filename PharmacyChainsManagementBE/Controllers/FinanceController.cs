using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PharmacyChainsManagementBE.Features.Finance;

namespace PharmacyChainsManagementBE.Controllers;

[Route("api/finance")]
[ApiController]
[Authorize(Roles = "Founder,Admin")]
public class FinanceController : ControllerBase
{
    private readonly IMediator _mediator;

    public FinanceController(IMediator mediator)
    {
        _mediator = mediator;
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
}
