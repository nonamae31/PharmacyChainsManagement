using System;
using System.Collections.Generic;
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
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;

    public BranchManagerController(
        PharmacyDbContext dbContext,
        IPasswordHashingStrategy passwordHashingStrategy)
    {
        _dbContext = dbContext;
        _passwordHashingStrategy = passwordHashingStrategy;
    }

    [HttpGet("dashboard")]
    [ProducesResponseType(typeof(BranchDashboardDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDashboard(
        [FromQuery] string trendPeriod = "month",
        CancellationToken cancellationToken = default)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var dashboard = await BranchManagerDataService.GetDashboardAsync(
            _dbContext,
            access.Value.BranchId,
            trendPeriod,
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
        [FromQuery] string? status = null,
        [FromQuery] string sort = "revenue_desc",
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
            status,
            sort,
            cancellationToken));
    }

    [HttpPost("staff")]
    [ProducesResponseType(typeof(BranchStaffDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateStaff(
        [FromBody] CreateBranchStaffRequestDto request,
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

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _dbContext.Users.AnyAsync(user => user.Email == normalizedEmail, cancellationToken))
        {
            return Conflict(new { message = "A user with this email already exists." });
        }

        var staffRole = await _dbContext.Roles.SingleOrDefaultAsync(
            role => role.RoleCode == "STAFF" && role.IsActive,
            cancellationToken);
        if (staffRole is null)
        {
            return Problem("The STAFF role is not configured.", statusCode: StatusCodes.Status500InternalServerError);
        }

        var now = DateTime.UtcNow;
        var staff = new User
        {
            UserId = Guid.NewGuid(),
            RoleId = staffRole.RoleId,
            BranchId = access.Value.BranchId,
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PasswordHash = _passwordHashingStrategy.HashPassword(request.Password),
            Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
            Status = "ACTIVE",
            MustChangePassword = true,
            CreatedAt = now,
            UpdatedAt = now
        };
        _dbContext.Users.Add(staff);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var response = new BranchStaffDto(
            staff.UserId,
            staff.FullName,
            staff.Email,
            staff.Phone,
            staff.Status,
            staff.CreatedAt);
        return CreatedAtAction(nameof(GetStaffPerformance), new { search = staff.Email }, response);
    }

    [HttpGet("staff-shifts")]
    [ProducesResponseType(typeof(IReadOnlyList<StaffShiftDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStaffShifts(
        [FromQuery] DateOnly? date = null,
        CancellationToken cancellationToken = default)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await BranchManagerDataService.GetStaffShiftsAsync(
            _dbContext,
            access.Value.BranchId,
            date ?? DateOnly.FromDateTime(DateTime.UtcNow),
            cancellationToken));
    }

    [HttpPost("staff-shifts")]
    [ProducesResponseType(typeof(StaffShiftDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpsertStaffShift(
        [FromBody] UpsertStaffShiftRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid || request.ShiftDate == default || request.StartTime >= request.EndTime)
        {
            ModelState.AddModelError(nameof(request.EndTime), "End time must be later than start time.");
            return ValidationProblem(ModelState);
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var shift = await BranchManagerDataService.UpsertStaffShiftAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return shift is null ? BadRequest(new { message = "The selected staff member does not belong to this branch." }) : Ok(shift);
    }

    [HttpPost("staff-assessments")]
    [ProducesResponseType(typeof(StaffAssessmentDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateStaffAssessment(
        [FromBody] CreateStaffAssessmentRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid || request.AssessmentDate == default)
        {
            return ValidationProblem(ModelState);
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var assessment = await BranchManagerDataService.CreateStaffAssessmentAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return assessment is null
            ? BadRequest(new { message = "The selected staff member does not belong to this branch." })
            : StatusCode(StatusCodes.Status201Created, assessment);
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

    [HttpGet("inventory/shipment-options")]
    [ProducesResponseType(typeof(ShipmentOptionsDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetShipmentOptions(CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await BranchManagerDataService.GetShipmentOptionsAsync(
            _dbContext,
            access.Value.BranchId,
            cancellationToken));
    }

    [HttpPost("inventory/shipments")]
    [ProducesResponseType(typeof(ShipmentRequestDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateShipment(
        [FromBody] CreateShipmentRequestDto request,
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

        var shipment = await BranchManagerDataService.CreateShipmentAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return shipment is null
            ? BadRequest(new { message = "The selected batch, source branch, or quantity is invalid." })
            : StatusCode(StatusCodes.Status201Created, shipment);
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
