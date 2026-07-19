using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.DTOs.StaffAttendance;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public sealed class StaffAttendanceService : IStaffAttendanceService
{
    private readonly PharmacyDbContext _dbContext;

    public StaffAttendanceService(PharmacyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<StaffAttendanceResponseDto>> GetAsync(
        Guid staffId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken)
    {
        if (from > to || to.DayNumber - from.DayNumber > 366)
        {
            throw new ArgumentException("Attendance date range is invalid.");
        }

        return await _dbContext.StaffAttendances
            .AsNoTracking()
            .Where(item =>
                item.StaffId == staffId &&
                item.AttendanceDate >= from &&
                item.AttendanceDate <= to)
            .OrderBy(item => item.AttendanceDate)
            .Select(item => ToDto(item))
            .ToListAsync(cancellationToken);
    }

    public async Task<StaffAttendanceResponseDto> CheckInAsync(
        Guid staffId,
        StaffAttendanceCheckInRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(DateTime.Now);
        if (request.AttendanceDate != today)
        {
            throw new InvalidOperationException("Check-in is only available for today.");
        }

        var existing = await _dbContext.StaffAttendances
            .AsNoTracking()
            .SingleOrDefaultAsync(
                item => item.StaffId == staffId &&
                        item.AttendanceDate == request.AttendanceDate,
                cancellationToken);
        if (existing is not null)
        {
            return ToDto(existing);
        }

        var user = await _dbContext.Users
            .AsNoTracking()
            .SingleOrDefaultAsync(
                item => item.UserId == staffId,
                cancellationToken)
            ?? throw new UnauthorizedAccessException("Staff account was not found.");
        if (user.BranchId is null)
        {
            throw new InvalidOperationException("Staff account is not assigned to a branch.");
        }

        var now = DateTime.UtcNow;
        var localTime = DateTime.Now.TimeOfDay;
        var shift = await _dbContext.StaffShifts
            .AsNoTracking()
            .SingleOrDefaultAsync(
                item => item.StaffId == staffId &&
                        item.BranchId == user.BranchId.Value &&
                        item.ShiftDate == request.AttendanceDate,
                cancellationToken);
        var status = shift is not null && localTime > shift.StartTime.ToTimeSpan()
            ? "LATE"
            : "PRESENT";

        var attendance = new StaffAttendance
        {
            AttendanceId = Guid.NewGuid(),
            StaffId = staffId,
            BranchId = user.BranchId.Value,
            AttendanceDate = request.AttendanceDate,
            CheckInTime = now,
            Status = status,
            CreatedAt = now,
            UpdatedAt = now
        };

        _dbContext.StaffAttendances.Add(attendance);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return ToDto(attendance);
    }

    private static StaffAttendanceResponseDto ToDto(StaffAttendance item) =>
        new(
            item.AttendanceId,
            item.AttendanceDate,
            item.CheckInTime,
            item.CheckOutTime,
            item.Status);
}
