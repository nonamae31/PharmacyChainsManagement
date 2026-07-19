namespace PharmacyChainsManagementBE.DTOs.StaffAttendance;

public sealed record StaffAttendanceResponseDto(
    Guid Id,
    DateOnly AttendanceDate,
    DateTime? CheckInTime,
    DateTime? CheckOutTime,
    string Status);

public sealed record StaffAttendanceCheckInRequestDto(DateOnly AttendanceDate);

public sealed record StaffAttendanceCheckOutRequestDto(DateOnly AttendanceDate);
