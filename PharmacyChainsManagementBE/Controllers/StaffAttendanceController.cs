using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.DTOs.StaffAttendance;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/staff-attendance")]
[Authorize(Roles = "Staff")]
public sealed class StaffAttendanceController : ControllerBase
{
    private readonly IStaffAttendanceService _service;

    public StaffAttendanceController(IStaffAttendanceService service)
    {
        _service = service;
    }

    [HttpGet]
    public Task<IReadOnlyList<StaffAttendanceResponseDto>> Get(
        [FromQuery] DateOnly from,
        [FromQuery] DateOnly to,
        CancellationToken cancellationToken) =>
        _service.GetAsync(GetStaffId(), from, to, cancellationToken);

    [HttpPost("check-in")]
    public Task<StaffAttendanceResponseDto> CheckIn(
        [FromBody] StaffAttendanceCheckInRequestDto request,
        CancellationToken cancellationToken) =>
        _service.CheckInAsync(GetStaffId(), request, cancellationToken);

    private Guid GetStaffId() =>
        Guid.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier) ??
            throw new UnauthorizedAccessException());
}
