using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.DTOs.Prescriptions;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/prescriptions")]
[Authorize(Roles = "Staff")]
public sealed class PrescriptionsController : ControllerBase
{
    private readonly IPrescriptionService _service;

    public PrescriptionsController(IPrescriptionService service) => _service = service;

    [HttpGet]
    public Task<IReadOnlyList<PrescriptionListItemResponseDto>> GetPrescriptions(CancellationToken cancellationToken) =>
        _service.GetPrescriptionsAsync(GetStaffId(), cancellationToken);

    [HttpGet("{prescriptionId:guid}")]
    public Task<PrescriptionResponseDto> GetPrescription(Guid prescriptionId, CancellationToken cancellationToken) =>
        _service.GetPrescriptionAsync(GetStaffId(), prescriptionId, cancellationToken);

    private Guid GetStaffId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new UnauthorizedAccessException());
}
