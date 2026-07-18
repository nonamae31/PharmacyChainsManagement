using System;
using System.Collections.Generic;

namespace PharmacyChainsManagementBE.DTOs.Prescriptions;

public sealed record PrescriptionListItemResponseDto(
    Guid PrescriptionId,
    string CustomerName,
    string? DoctorName,
    DateOnly PrescriptionDate,
    string Status,
    int ItemCount);

public sealed record PrescriptionLineResponseDto(
    Guid PrescriptionDetailId,
    Guid MedicineId,
    string MedicineName,
    string? Dosage,
    string? Frequency,
    string? Duration,
    int Quantity);

public sealed record PrescriptionResponseDto(
    Guid PrescriptionId,
    string CustomerName,
    string? DoctorName,
    DateOnly PrescriptionDate,
    string Status,
    IReadOnlyList<PrescriptionLineResponseDto> Items);
