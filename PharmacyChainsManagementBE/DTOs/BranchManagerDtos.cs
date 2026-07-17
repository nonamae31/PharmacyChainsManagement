using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs;

public sealed record RevenuePointDto(DateOnly Date, decimal Revenue);

public sealed record DashboardMetricDto(
    decimal TodayRevenue,
    decimal RevenueChangePercent,
    int ActiveStaff,
    int TotalStaff,
    int StockAlerts,
    decimal BranchEfficiencyPercent);

public sealed record DashboardStaffDto(
    Guid StaffId,
    string FullName,
    string RoleName,
    decimal SalesRevenue);

public sealed record DashboardInventoryDto(
    Guid MedicineId,
    string Sku,
    string MedicineName,
    string Category,
    int CurrentStock,
    int ReorderPoint,
    string Status);

public sealed record BranchDashboardDto(
    Guid BranchId,
    string BranchName,
    DashboardMetricDto Metrics,
    IReadOnlyList<RevenuePointDto> RevenueTrend,
    IReadOnlyList<DashboardStaffDto> TopStaff,
    IReadOnlyList<DashboardInventoryDto> InventoryAlerts);

public sealed record CategoryRevenueDto(string Category, decimal Revenue, decimal ContributionPercent);

public sealed record TimeBlockPerformanceDto(
    string TimeBlock,
    int Transactions,
    decimal Revenue,
    decimal AverageOrder,
    string Status);

public sealed record BranchRevenueDto(
    Guid BranchId,
    DateOnly FromDate,
    DateOnly ToDate,
    decimal TotalRevenue,
    decimal AverageTicket,
    int Transactions,
    decimal? GrossMarginPercent,
    IReadOnlyList<RevenuePointDto> RevenueTrend,
    IReadOnlyList<CategoryRevenueDto> CategoryRevenue,
    IReadOnlyList<TimeBlockPerformanceDto> PerformanceByTime);

public sealed record StaffPerformanceRowDto(
    Guid StaffId,
    string FullName,
    string Email,
    string RoleName,
    string Status,
    decimal SalesRevenue,
    decimal? SalesTarget,
    decimal? TargetProgressPercent,
    decimal? CustomerRating,
    decimal? AttendancePercent,
    decimal? PerformanceScore);

public sealed record StaffTrendPointDto(string Label, decimal Revenue);

public sealed record StaffFeedbackDto(
    Guid AssessmentId,
    Guid StaffId,
    string StaffName,
    DateOnly AssessmentDate,
    decimal PerformanceScore,
    string Notes);

public sealed record StaffPerformanceDto(
    Guid BranchId,
    decimal? AverageSalesTargetPercent,
    decimal? CustomerSatisfaction,
    decimal? TeamAttendancePercent,
    StaffPerformanceRowDto? TopPerformer,
    IReadOnlyList<StaffPerformanceRowDto> Staff,
    IReadOnlyList<StaffTrendPointDto> Trend,
    IReadOnlyList<StaffFeedbackDto> RecentFeedback);

public sealed record BranchInventoryRowDto(
    Guid MedicineId,
    string Sku,
    string MedicineName,
    string Category,
    int CurrentStock,
    int ReorderPoint,
    string Status,
    string Supplier,
    DateTime LastSync,
    decimal InventoryValue);

public sealed record BranchInventoryDto(
    Guid BranchId,
    int TotalItems,
    int CriticalStock,
    int InTransit,
    decimal InventoryValue,
    int Page,
    int PageSize,
    int TotalRecords,
    IReadOnlyList<string> Categories,
    IReadOnlyList<BranchInventoryRowDto> Items);

public sealed class ConfirmDailyRevenueRequestDto
{
    [Range(0, 999999999999)]
    public decimal ActualCash { get; init; }

    [Range(0, 999999999999)]
    public decimal ActualBankTransfer { get; init; }

    [Range(0, 999999999999)]
    public decimal ActualOther { get; init; }

    [StringLength(500)]
    public string? DifferenceReason { get; init; }
}

public sealed record DailyRevenueConfirmationDto(
    Guid ConfirmationId,
    DateOnly RevenueDate,
    decimal SystemAmount,
    decimal ActualAmount,
    decimal Difference,
    bool IsMatched,
    DateTime ConfirmedAt);

public sealed class CreateBranchStaffRequestDto
{
    [Required, StringLength(150, MinimumLength = 2)]
    public string FullName { get; init; } = string.Empty;

    [Required, EmailAddress, StringLength(150)]
    public string Email { get; init; } = string.Empty;

    [Required, StringLength(100, MinimumLength = 8)]
    public string Password { get; init; } = string.Empty;

    [StringLength(30)]
    public string? Phone { get; init; }
}

public sealed record BranchStaffDto(
    Guid StaffId,
    string FullName,
    string Email,
    string? Phone,
    string Status,
    DateTime CreatedAt);

public sealed class UpdateStaffStatusRequestDto
{
    [Required, RegularExpression("^(ACTIVE|INACTIVE)$")]
    public string Status { get; init; } = string.Empty;
}

public sealed class UpsertStaffShiftRequestDto
{
    [Required]
    public Guid StaffId { get; init; }

    public DateOnly ShiftDate { get; init; }

    public TimeOnly StartTime { get; init; }

    public TimeOnly EndTime { get; init; }

    [Required, StringLength(30)]
    public string Status { get; init; } = "SCHEDULED";

    [StringLength(500)]
    public string? Notes { get; init; }
}

public sealed record StaffShiftDto(
    Guid ShiftId,
    Guid StaffId,
    string StaffName,
    DateOnly ShiftDate,
    TimeOnly StartTime,
    TimeOnly EndTime,
    string Status,
    string? Notes,
    DateTime UpdatedAt);

public sealed class CreateStaffAssessmentRequestDto
{
    [Required]
    public Guid StaffId { get; init; }

    public DateOnly AssessmentDate { get; init; }

    [Range(typeof(decimal), "0", "999999999999")]
    public decimal SalesTarget { get; init; }

    [Range(typeof(decimal), "0", "5")]
    public decimal CustomerRating { get; init; }

    [Range(typeof(decimal), "0", "100")]
    public decimal AttendancePercent { get; init; }

    [Range(typeof(decimal), "0", "100")]
    public decimal PerformanceScore { get; init; }

    [StringLength(1000)]
    public string? Notes { get; init; }
}

public sealed record StaffAssessmentDto(
    Guid AssessmentId,
    Guid StaffId,
    DateOnly AssessmentDate,
    decimal SalesTarget,
    decimal CustomerRating,
    decimal AttendancePercent,
    decimal PerformanceScore,
    string? Notes,
    DateTime CreatedAt);

public sealed record TransferSourceBranchDto(Guid BranchId, string BranchName);

public sealed record TransferBatchOptionDto(
    Guid BranchId,
    Guid MedicineId,
    Guid BatchId,
    string MedicineName,
    string BatchNumber,
    int AvailableQuantity,
    DateOnly ExpiryDate);

public sealed record ShipmentOptionsDto(
    IReadOnlyList<TransferSourceBranchDto> SourceBranches,
    IReadOnlyList<TransferBatchOptionDto> Batches);

public sealed class CreateShipmentRequestDto
{
    [Required]
    public Guid FromBranchId { get; init; }

    [Required]
    public Guid BatchId { get; init; }

    [Range(1, int.MaxValue)]
    public int Quantity { get; init; }

    [StringLength(1000)]
    public string? Notes { get; init; }
}

public sealed record ShipmentRequestDto(
    Guid TransferId,
    Guid FromBranchId,
    Guid ToBranchId,
    Guid MedicineId,
    Guid BatchId,
    int Quantity,
    string Status,
    DateOnly RequestDate);
