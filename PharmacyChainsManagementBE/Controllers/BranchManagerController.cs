using System;
using System.Globalization;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Authorize(Roles = "BRANCH_MANAGER")]
[Route("api/v1/branch-manager")]
public sealed class BranchManagerController : ControllerBase
{
    private const int MaximumReportDays = 366;
    private readonly PharmacyDbContext _dbContext;

    public BranchManagerController(PharmacyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet("dashboard")]
    [ProducesResponseType(typeof(BranchDashboardDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDashboard(CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var dashboard = await BranchManagerDataService.GetDashboardAsync(
            _dbContext,
            access.Value.BranchId,
            cancellationToken);
        return dashboard is null ? NotFound() : Ok(dashboard);
    }

    [HttpGet("revenue")]
    [ProducesResponseType(typeof(BranchRevenueDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetRevenue(
        [FromQuery] string period = "daily",
        [FromQuery] DateOnly? fromDate = null,
        [FromQuery] DateOnly? toDate = null,
        CancellationToken cancellationToken = default)
    {
        var range = ResolveDateRange(period, fromDate, toDate);
        if (range is null)
        {
            return BadRequest(new { message = "The selected date range is invalid or exceeds 366 days." });
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await BranchManagerDataService.GetRevenueAsync(
            _dbContext,
            access.Value.BranchId,
            range.Value.FromDate,
            range.Value.ToDate,
            cancellationToken));
    }

    [HttpGet("revenue/export.csv")]
    public async Task<IActionResult> ExportRevenue(
        [FromQuery] string period = "daily",
        [FromQuery] DateOnly? fromDate = null,
        [FromQuery] DateOnly? toDate = null,
        CancellationToken cancellationToken = default)
    {
        var range = ResolveDateRange(period, fromDate, toDate);
        if (range is null)
        {
            return BadRequest(new { message = "The selected date range is invalid or exceeds 366 days." });
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var report = await BranchManagerDataService.GetRevenueAsync(
            _dbContext,
            access.Value.BranchId,
            range.Value.FromDate,
            range.Value.ToDate,
            cancellationToken);
        var csv = new StringBuilder("date,revenue\r\n");
        foreach (var point in report.RevenueTrend)
        {
            csv.Append(point.Date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture))
                .Append(',')
                .Append(point.Revenue.ToString(CultureInfo.InvariantCulture))
                .Append("\r\n");
        }

        return File(Encoding.UTF8.GetBytes(csv.ToString()), "text/csv", $"branch-revenue-{range.Value.FromDate:yyyyMMdd}-{range.Value.ToDate:yyyyMMdd}.csv");
    }

    [HttpGet("staff-performance")]
    [ProducesResponseType(typeof(StaffPerformanceDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStaffPerformance(
        [FromQuery] string? search = null,
        CancellationToken cancellationToken = default)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await BranchManagerDataService.GetStaffPerformanceAsync(
            _dbContext,
            access.Value.BranchId,
            today.AddDays(-29),
            today,
            search,
            cancellationToken));
    }

    [HttpGet("inventory")]
    [ProducesResponseType(typeof(BranchInventoryDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetInventory(
        [FromQuery] string? search = null,
        [FromQuery] string? category = null,
        [FromQuery] string? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await BranchManagerDataService.GetInventoryAsync(
            _dbContext,
            access.Value.BranchId,
            search,
            category,
            status,
            page,
            pageSize,
            cancellationToken));
    }

    [HttpGet("inventory/export.csv")]
    public async Task<IActionResult> ExportInventory(CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var report = await BranchManagerDataService.GetInventoryAsync(
            _dbContext,
            access.Value.BranchId,
            null,
            null,
            null,
            1,
            int.MaxValue,
            cancellationToken);
        var csv = new StringBuilder("sku,medicine,category,current_stock,reorder_point,status,supplier,inventory_value\r\n");
        foreach (var item in report.Items)
        {
            csv.Append(EscapeCsv(item.Sku)).Append(',')
                .Append(EscapeCsv(item.MedicineName)).Append(',')
                .Append(EscapeCsv(item.Category)).Append(',')
                .Append(item.CurrentStock).Append(',')
                .Append(item.ReorderPoint).Append(',')
                .Append(EscapeCsv(item.Status)).Append(',')
                .Append(EscapeCsv(item.Supplier)).Append(',')
                .Append(item.InventoryValue.ToString(CultureInfo.InvariantCulture))
                .Append("\r\n");
        }

        return File(Encoding.UTF8.GetBytes(csv.ToString()), "text/csv", $"branch-inventory-{DateTime.UtcNow:yyyyMMdd}.csv");
    }

    [HttpPost("daily-revenue/confirm")]
    [ProducesResponseType(typeof(DailyRevenueConfirmationDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> ConfirmDailyRevenue(
        [FromBody] ConfirmDailyRevenueRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var systemAmount = await _dbContext.PaymentTransactions
            .AsNoTracking()
            .Where(payment => payment.Invoice.BranchId == access.Value.BranchId
                && payment.Invoice.InvoiceDate == today
                && payment.PaymentStatus == "PAID")
            .SumAsync(payment => (decimal?)payment.Amount, cancellationToken) ?? 0m;
        var actualAmount = request.ActualCash + request.ActualBankTransfer + request.ActualOther;
        if (actualAmount != systemAmount && string.IsNullOrWhiteSpace(request.DifferenceReason))
        {
            ModelState.AddModelError(nameof(request.DifferenceReason), "A reason is required when actual and system revenue differ.");
            return ValidationProblem(ModelState);
        }

        return Ok(await BranchManagerDataService.ConfirmDailyRevenueAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken));
    }

    private async Task<(Guid ManagerId, Guid BranchId)?> ResolveAccessAsync(CancellationToken cancellationToken)
    {
        var rawUserId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? User.Claims.FirstOrDefault(claim => claim.Type.EndsWith("/nameidentifier", StringComparison.OrdinalIgnoreCase))?.Value;
        if (!Guid.TryParse(rawUserId, out var managerId))
        {
            return null;
        }

        var branchId = await BranchManagerDataService.ResolveAssignedBranchIdAsync(_dbContext, managerId, cancellationToken);
        return branchId.HasValue ? (managerId, branchId.Value) : null;
    }

    private static (DateOnly FromDate, DateOnly ToDate)? ResolveDateRange(
        string period,
        DateOnly? fromDate,
        DateOnly? toDate)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        (DateOnly FromDate, DateOnly ToDate)? range = period.ToLowerInvariant() switch
        {
            "daily" => (FromDate: today.AddDays(-29), ToDate: today),
            "weekly" => (FromDate: today.AddDays(-7 * 11), ToDate: today),
            "monthly" => (FromDate: today.AddMonths(-11), ToDate: today),
            "custom" when fromDate.HasValue && toDate.HasValue => (FromDate: fromDate.Value, ToDate: toDate.Value),
            _ => null
        };
        if (range is null || range.Value.FromDate > range.Value.ToDate
            || range.Value.ToDate.DayNumber - range.Value.FromDate.DayNumber + 1 > MaximumReportDays)
        {
            return null;
        }

        return range;
    }

    private static string EscapeCsv(string value)
    {
        return $"\"{value.Replace("\"", "\"\"")}\"";
    }
}
