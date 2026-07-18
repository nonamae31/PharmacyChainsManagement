using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.Prescriptions;

namespace PharmacyChainsManagementBE.Services;

public interface IPrescriptionService
{
    Task<IReadOnlyList<PrescriptionListItemResponseDto>> GetPrescriptionsAsync(Guid staffId, CancellationToken cancellationToken);
    Task<PrescriptionResponseDto> GetPrescriptionAsync(Guid staffId, Guid prescriptionId, CancellationToken cancellationToken);
}
