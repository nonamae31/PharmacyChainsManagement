using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Common.Exceptions;
using PharmacyChainsManagementBE.DTOs.Prescriptions;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public sealed class PrescriptionService : IPrescriptionService
{
    private readonly PharmacyDbContext _context;

    public PrescriptionService(PharmacyDbContext context) => _context = context;

    public async Task<IReadOnlyList<PrescriptionListItemResponseDto>> GetPrescriptionsAsync(Guid staffId, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);

        return await _context.Prescriptions
            .AsNoTracking()
            .Where(prescription => prescription.BranchId == branchId)
            .OrderByDescending(prescription => prescription.PrescriptionDate)
            .ThenByDescending(prescription => prescription.CreatedAt)
            .Select(prescription => new PrescriptionListItemResponseDto(
                prescription.PrescriptionId,
                prescription.CustomerName,
                prescription.DoctorName,
                prescription.PrescriptionDate,
                prescription.Status,
                prescription.PrescriptionDetails.Count))
            .ToListAsync(cancellationToken);
    }

    public async Task<PrescriptionResponseDto> GetPrescriptionAsync(Guid staffId, Guid prescriptionId, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var prescription = await _context.Prescriptions
            .AsNoTracking()
            .Include(item => item.PrescriptionDetails)
            .ThenInclude(item => item.Medicine)
            .SingleOrDefaultAsync(item => item.PrescriptionId == prescriptionId && item.BranchId == branchId, cancellationToken)
            ?? throw new DataNotFoundException("Prescription was not found.");

        return new PrescriptionResponseDto(
            prescription.PrescriptionId,
            prescription.CustomerName,
            prescription.DoctorName,
            prescription.PrescriptionDate,
            prescription.Status,
            prescription.PrescriptionDetails
                .Select(item => new PrescriptionLineResponseDto(
                    item.PrescriptionDetailId,
                    item.MedicineId,
                    item.Medicine.MedicineName,
                    item.Dosage,
                    item.Frequency,
                    item.Duration,
                    item.Quantity))
                .ToList());
    }

    private async Task<Guid> GetStaffBranchIdAsync(Guid staffId, CancellationToken cancellationToken) =>
        await _context.Users
            .AsNoTracking()
            .Where(user => user.UserId == staffId && user.Status == "ACTIVE")
            .Select(user => user.BranchId)
            .SingleOrDefaultAsync(cancellationToken)
        ?? throw new InvalidOperationException("The staff account is not assigned to an active branch.");
}
