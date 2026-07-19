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
    private const int MaximumShiftHours = 12;
    private readonly PharmacyDbContext _dbContext;
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;
    private readonly IStockReplenishmentService _stockReplenishmentService;

    public BranchManagerController(
        PharmacyDbContext dbContext,
        IPasswordHashingStrategy passwordHashingStrategy,
        IStockReplenishmentService stockReplenishmentService)
    {
        _dbContext = dbContext;
        _passwordHashingStrategy = passwordHashingStrategy;
        _stockReplenishmentService = stockReplenishmentService;
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
        [FromQuery] DateOnly? fromDate = null,
        [FromQuery] DateOnly? toDate = null,
        CancellationToken cancellationToken = default)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var selectedDate = date ?? BranchManagerDataService.GetVietnamToday();
        var rangeStart = fromDate ?? selectedDate;
        var rangeEnd = toDate ?? selectedDate;
        if (rangeStart > rangeEnd || rangeEnd.DayNumber - rangeStart.DayNumber > 6)
        {
            return BadRequest(new { message = "The staff shift range must contain no more than seven days." });
        }

        return Ok(await BranchManagerDataService.GetStaffShiftsAsync(
            _dbContext,
            access.Value.BranchId,
            rangeStart,
            rangeEnd,
            cancellationToken));
    }

    [HttpPost("staff-shifts")]
    [ProducesResponseType(typeof(StaffShiftDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpsertStaffShift(
        [FromBody] UpsertStaffShiftRequestDto request,
        CancellationToken cancellationToken)
    {
        var normalizedStatus = request.Status.Trim().ToUpperInvariant();
        var today = BranchManagerDataService.GetVietnamToday();
        if (request.ShiftDate == default)
        {
            ModelState.AddModelError(nameof(request.ShiftDate), "Shift date is required.");
        }
        else if (normalizedStatus == "SCHEDULED" && request.ShiftDate < today)
        {
            ModelState.AddModelError(
                nameof(request.ShiftDate),
                "A scheduled shift cannot be created in the past.");
        }
        if (normalizedStatus == "SCHEDULED"
            && request.ShiftDate.DayOfWeek == DayOfWeek.Sunday)
        {
            ModelState.AddModelError(
                nameof(request.ShiftDate),
                "Sunday is the fixed weekly day off and cannot contain a scheduled shift.");
        }
        if (normalizedStatus == "SCHEDULED" && request.StartTime >= request.EndTime)
        {
            ModelState.AddModelError(nameof(request.EndTime), "End time must be later than start time.");
        }
        if (normalizedStatus == "SCHEDULED"
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

        var isActiveBranchStaff = await _dbContext.Users
            .AsNoTracking()
            .AnyAsync(user => user.UserId == request.StaffId
                && user.BranchId == access.Value.BranchId
                && user.Role.RoleCode == "STAFF"
                && user.Status == "ACTIVE",
                cancellationToken);
        if (!isActiveBranchStaff)
        {
            return BadRequest(new { message = "The selected staff member does not belong to this branch or is inactive." });
        }

        var existingShift = await _dbContext.StaffShifts
            .AsNoTracking()
            .SingleOrDefaultAsync(shift => shift.BranchId == access.Value.BranchId
                && shift.StaffId == request.StaffId
                && shift.ShiftDate == request.ShiftDate,
                cancellationToken);
        var hasWeeklySchedule = await _dbContext.StaffWeeklySchedules
            .AsNoTracking()
            .AnyAsync(schedule => schedule.BranchId == access.Value.BranchId
                && schedule.StaffId == request.StaffId,
                cancellationToken);
        if (normalizedStatus != "SCHEDULED"
            && existingShift is null
            && !hasWeeklySchedule)
        {
            return BadRequest(new
            {
                message = "This staff member has no scheduled shift on the selected date to mark as off or cancelled."
            });
        }

        var isCoveredByConfirmedPayroll = await _dbContext.StaffPayrolls
            .AsNoTracking()
            .AnyAsync(payroll => payroll.BranchId == access.Value.BranchId
                && payroll.StaffId == request.StaffId
                && payroll.Status == "CONFIRMED"
                && payroll.PeriodStart <= request.ShiftDate
                && payroll.PeriodEnd >= request.ShiftDate,
                cancellationToken);
        if (isCoveredByConfirmedPayroll)
        {
            return Conflict(new
            {
                message = "This shift belongs to a confirmed payroll period and can no longer be changed."
            });
        }

        if (normalizedStatus == "SCHEDULED")
        {
            var conflictingShift = await _dbContext.StaffShifts
                .AsNoTracking()
                .Where(shift => shift.BranchId == access.Value.BranchId
                    && shift.ShiftDate == request.ShiftDate
                    && shift.StaffId != request.StaffId
                    && shift.Status.ToUpper() == "SCHEDULED"
                    && shift.StartTime < request.EndTime
                    && request.StartTime < shift.EndTime)
                .Join(
                    _dbContext.Users.AsNoTracking(),
                    shift => shift.StaffId,
                    staff => staff.UserId,
                    (shift, staff) => new
                    {
                        StaffName = staff.FullName,
                        shift.StartTime,
                        shift.EndTime
                    })
                .OrderBy(item => item.StartTime)
                .FirstOrDefaultAsync(cancellationToken);
            if (conflictingShift is not null)
            {
                var start = conflictingShift.StartTime.ToString("HH:mm", CultureInfo.InvariantCulture);
                var end = conflictingShift.EndTime.ToString("HH:mm", CultureInfo.InvariantCulture);
                return Conflict(new
                {
                    message = $"This time slot is already assigned to {conflictingShift.StaffName} ({start} - {end}). Mark the existing shift as OFF or CANCELLED before assigning a replacement."
                });
            }

            var recurringConflict = await _dbContext.StaffWeeklySchedules
                .AsNoTracking()
                .Where(schedule => schedule.BranchId == access.Value.BranchId
                    && schedule.StaffId != request.StaffId
                    && schedule.StartTime < request.EndTime
                    && request.StartTime < schedule.EndTime
                    && (request.ApplyToWeeklySchedule
                        || !_dbContext.StaffShifts.Any(shift =>
                            shift.BranchId == access.Value.BranchId
                            && shift.StaffId == schedule.StaffId
                            && shift.ShiftDate == request.ShiftDate
                            && shift.Status.ToUpper() != "SCHEDULED")))
                .Join(
                    _dbContext.Users.AsNoTracking(),
                    schedule => schedule.StaffId,
                    staff => staff.UserId,
                    (schedule, staff) => new
                    {
                        StaffName = staff.FullName,
                        schedule.StartTime,
                        schedule.EndTime
                    })
                .OrderBy(item => item.StartTime)
                .FirstOrDefaultAsync(cancellationToken);
            if (recurringConflict is not null)
            {
                var start = recurringConflict.StartTime.ToString("HH:mm", CultureInfo.InvariantCulture);
                var end = recurringConflict.EndTime.ToString("HH:mm", CultureInfo.InvariantCulture);
                return Conflict(new
                {
                    message = $"This recurring time slot belongs to {recurringConflict.StaffName} ({start} - {end}). Mark that employee off for this date or change the weekly schedule first."
                });
            }
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

    [HttpGet("staff-payroll")]
    [ProducesResponseType(typeof(StaffPayrollSummaryDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStaffPayroll(
        [FromQuery] DateOnly? fromDate = null,
        [FromQuery] DateOnly? toDate = null,
        CancellationToken cancellationToken = default)
    {
        var today = BranchManagerDataService.GetVietnamToday();
        var periodStart = fromDate ?? new DateOnly(today.Year, today.Month, 1);
        var periodEnd = toDate ?? today;
        if (periodStart > periodEnd
            || periodEnd.DayNumber - periodStart.DayNumber + 1 > MaximumReportDays)
        {
            return BadRequest(new { message = "The payroll period is invalid or exceeds 366 days." });
        }

        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await BranchManagerDataService.GetStaffPayrollAsync(
            _dbContext,
            access.Value.BranchId,
            periodStart,
            periodEnd,
            cancellationToken));
    }

    [HttpPut("staff-pay-rates")]
    [ProducesResponseType(typeof(StaffPayRateDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpsertStaffPayRate(
        [FromBody] UpdateStaffPayRateRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = BranchManagerDataService.GetVietnamToday();
        if (request.EffectiveFrom == default || request.EffectiveFrom > today)
        {
            ModelState.AddModelError(
                nameof(request.EffectiveFrom),
                "Effective date is required and cannot be in the future.");
        }
        if (!HasAtMostTwoDecimalPlaces(request.HourlyRate))
        {
            ModelState.AddModelError(nameof(request.HourlyRate), "Hourly rate cannot have more than two decimal places.");
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

        var payRate = await BranchManagerDataService.UpsertStaffPayRateAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return payRate is null
            ? BadRequest(new { message = "The selected staff member does not belong to this branch." })
            : Ok(payRate);
    }

    [HttpPost("staff-payroll")]
    [ProducesResponseType(typeof(StaffPayrollRowDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpsertStaffPayroll(
        [FromBody] UpsertStaffPayrollRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = BranchManagerDataService.GetVietnamToday();
        if (request.PeriodStart == default || request.PeriodEnd == default
            || request.PeriodStart > request.PeriodEnd
            || request.PeriodEnd > today
            || request.PeriodEnd.DayNumber - request.PeriodStart.DayNumber + 1 > MaximumReportDays)
        {
            ModelState.AddModelError(nameof(request.PeriodEnd), "Payroll period must be valid, not in the future, and no longer than 366 days.");
        }
        if (!HasAtMostTwoDecimalPlaces(request.Bonus)
            || !HasAtMostTwoDecimalPlaces(request.Deduction))
        {
            ModelState.AddModelError(nameof(request.Bonus), "Bonus and deduction cannot have more than two decimal places.");
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

        var result = await BranchManagerDataService.UpsertStaffPayrollAsync(
            _dbContext,
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        return result.Payroll is null
            ? BadRequest(new { message = result.ErrorMessage })
            : Ok(result.Payroll);
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

    [HttpGet("inventory/replenishment-options")]
    [ProducesResponseType(typeof(IReadOnlyList<StockReplenishmentOptionDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStockReplenishmentOptions(CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await _stockReplenishmentService.GetOptionsAsync(
            access.Value.BranchId,
            cancellationToken));
    }

    [HttpGet("inventory/replenishment-requests")]
    [ProducesResponseType(typeof(IReadOnlyList<StockReplenishmentRequestDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStockReplenishmentRequests(CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        return Ok(await _stockReplenishmentService.GetBranchRequestsAsync(
            access.Value.BranchId,
            cancellationToken));
    }

    [HttpPost("inventory/replenishment-requests")]
    [ProducesResponseType(typeof(StockReplenishmentRequestDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateStockReplenishmentRequest(
        [FromBody] CreateStockReplenishmentRequestDto request,
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

        var result = await _stockReplenishmentService.CreateAsync(
            access.Value.ManagerId,
            access.Value.BranchId,
            request,
            cancellationToken);
        if (result.IsSuccess)
        {
            return StatusCode(StatusCodes.Status201Created, result.Value);
        }

        return result.Error.Type == PharmacyChainsManagementBE.Common.ErrorType.Conflict
            ? Conflict(new { message = result.Error.Message })
            : BadRequest(new { message = result.Error.Message });
    }

    [HttpPost("inventory/replenishment-requests/{requestId:guid}/confirm-received")]
    [ProducesResponseType(typeof(StockReplenishmentRequestDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> ConfirmStockReplenishmentReceived(
        Guid requestId,
        CancellationToken cancellationToken)
    {
        var access = await ResolveAccessAsync(cancellationToken);
        if (access is null)
        {
            return Forbid();
        }

        var result = await _stockReplenishmentService.ConfirmReceivedAsync(
            requestId,
            access.Value.ManagerId,
            access.Value.BranchId,
            cancellationToken);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }

        return result.Error.Type switch
        {
            PharmacyChainsManagementBE.Common.ErrorType.NotFound =>
                NotFound(new { message = result.Error.Message }),
            PharmacyChainsManagementBE.Common.ErrorType.Conflict =>
                Conflict(new { message = result.Error.Message }),
            _ => BadRequest(new { message = result.Error.Message })
        };
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
