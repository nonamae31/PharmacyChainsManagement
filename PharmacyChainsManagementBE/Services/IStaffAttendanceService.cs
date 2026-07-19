using PharmacyChainsManagementBE.DTOs.StaffAttendance;

namespace PharmacyChainsManagementBE.Services;

public interface IStaffAttendanceService
{
    Task<IReadOnlyList<StaffAttendanceResponseDto>> GetAsync(
        Guid staffId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken);

    Task<StaffAttendanceResponseDto> CheckInAsync(
        Guid staffId,
        StaffAttendanceCheckInRequestDto request,
        CancellationToken cancellationToken);

    Task<StaffAttendanceResponseDto> CheckOutAsync(
        Guid staffId,
        StaffAttendanceCheckOutRequestDto request,
        CancellationToken cancellationToken);
}
