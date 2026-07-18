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
[Authorize(Roles = "BranchManager")]
[Route("api/v1/branch-manager")]
public sealed class BranchManagerController : ControllerBase
{
    private const int MaximumReportDays = 366;
    private const int MaximumShiftHours = 16;
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
        if (request.FullName.Trim().Length < 2)
        {
            ModelState.AddModelError(
                nameof(request.FullName),
                "Full name must contain at least two non-whitespace characters.");
        }
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

    [HttpPatch("staff/{staffId:guid}/status")]
    [ProducesResponseType(typeof(BranchStaffDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateStaffStatus(
        Guid staffId,
        [FromBody] UpdateStaffStatusRequestDto request,
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

        var normalizedStatus = request.Status.Trim().ToUpperInvariant();
        if (normalizedStatus == "INACTIVE")
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var hasScheduledShift = await _dbContext.StaffShifts
                .AsNoTracking()
                .AnyAsync(shift => shift.BranchId == access.Value.BranchId
                    && shift.StaffId == staffId
                    && shift.ShiftDate >= today
                    && shift.Status == "SCHEDULED",
                    cancellationToken);
            if (hasScheduledShift)
            {
                return Conflict(new
                {
                    message = "Cancel the staff member's current and future scheduled shifts before deactivation."
                });
            }
        }

        var staff = await BranchManagerDataService.UpdateStaffStatusAsync(
            _dbContext,
            access.Value.BranchId,
            staffId,
            normalizedStatus,
            cancellationToken);
        return staff is null
            ? BadRequest(new { message = "The selected staff member does not belong to this branch." })
            : Ok(staff);
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
        var normalizedStatus = request.Status.Trim().ToUpperInvariant();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (request.ShiftDate == default || request.ShiftDate < today)
        {
            ModelState.AddModelError(
                nameof(request.ShiftDate),
                "Shift date cannot be in the past.");
        }
        if (normalizedStatus != "OFF" && request.StartTime >= request.EndTime)
        {
            ModelState.AddModelError(nameof(request.EndTime), "End time must be later than start time.");
        }
        if (normalizedStatus != "OFF"
            && request.EndTime - request.StartTime > TimeSpan.FromHours(MaximumShiftHours))
        {
            ModelState.AddModelError(
                nameof(request.EndTime),
                $"A shift cannot exceed {MaximumShiftHours} hours.");
        }
        if (!ModelState.IsValid)
        {
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
        return shift is null
            ? BadRequest(new { message = "The selected staff member does not belong to this branch or is inactive." })
            : Ok(shift);
    }

    [HttpPost("staff-assessments")]
    [ProducesResponseType(typeof(StaffAssessmentDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateStaffAssessment(
        [FromBody] CreateStaffAssessmentRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (request.AssessmentDate == default || request.AssessmentDate > today)
        {
            ModelState.AddModelError(
                nameof(request.AssessmentDate),
                "Assessment date cannot be in the future.");
        }
        if (!HasAtMostTwoDecimalPlaces(request.SalesTarget)
            || !HasAtMostTwoDecimalPlaces(request.CustomerRating)
            || !HasAtMostTwoDecimalPlaces(request.AttendancePercent)
            || !HasAtMostTwoDecimalPlaces(request.PerformanceScore))
        {
            ModelState.AddModelError(
                nameof(request.PerformanceScore),
                "Assessment numbers cannot have more than two decimal places.");
        }
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var assessmentExists = await _dbContext.StaffAssessments
            .AsNoTracking()
            .AnyAsync(assessment => assessment.BranchId == access.Value.BranchId
                && assessment.StaffId == request.StaffId
                && assessment.AssessmentDate == request.AssessmentDate,
                cancellationToken);
        if (assessmentExists)
        {
            return Conflict(new
            {
                message = "This staff member already has an assessment for the selected date."
            });
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

    [HttpPost("daily-revenue/confirm")]
    [ProducesResponseType(typeof(DailyRevenueConfirmationDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> ConfirmDailyRevenue(
        [FromBody] ConfirmDailyRevenueRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!HasAtMostTwoDecimalPlaces(request.ActualCash)
            || !HasAtMostTwoDecimalPlaces(request.ActualBankTransfer)
            || !HasAtMostTwoDecimalPlaces(request.ActualOther))
        {
            ModelState.AddModelError(
                nameof(request.ActualCash),
                "Revenue amounts cannot have more than two decimal places.");
        }
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
        var existingConfirmation = await BranchManagerDataService.GetDailyRevenueConfirmationAsync(
            _dbContext,
            access.Value.BranchId,
            today,
            cancellationToken);
        if (existingConfirmation is not null)
        {
            return Conflict(new
            {
                message = "Daily revenue has already been confirmed for today."
            });
        }

        var systemAmount = await BranchManagerDataService.GetDailySystemRevenueAsync(
            _dbContext,
            access.Value.BranchId,
            today,
            cancellationToken);
        var actualAmount = request.ActualCash + request.ActualBankTransfer + request.ActualOther;
        if (actualAmount != systemAmount && string.IsNullOrWhiteSpace(request.DifferenceReason))
        {
            ModelState.AddModelError(nameof(request.DifferenceReason), "A reason is required when actual and system revenue differ.");
            return ValidationProblem(ModelState);
        }

        var confirmation = await BranchManagerDataService.ConfirmDailyRevenueAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return confirmation is null
            ? Conflict(new
            {
                message = "Daily revenue has already been confirmed for today."
            })
            : Ok(confirmation);
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

    private static bool HasAtMostTwoDecimalPlaces(decimal value)
    {
        return decimal.Round(value, 2) == value;
    }

    private static (DateOnly FromDate, DateOnly ToDate)? ResolveDateRange(
        string period,
        DateOnly? fromDate,
        DateOnly? toDate)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        (DateOnly FromDate, DateOnly ToDate)? range = period.ToLowerInvariant() switch
        {
            "daily" => (FromDate: today, ToDate: today),
            "weekly" => (FromDate: today.AddDays(-6), ToDate: today),
            "monthly" => (FromDate: new DateOnly(today.Year, today.Month, 1), ToDate: today),
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
