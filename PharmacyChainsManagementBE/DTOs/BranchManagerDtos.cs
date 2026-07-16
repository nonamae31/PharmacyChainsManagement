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
    string RoleName,
    decimal SalesRevenue,
    decimal? SalesTarget,
    decimal? TargetProgressPercent,
    decimal? CustomerRating,
    decimal? AttendancePercent,
    decimal? PerformanceScore);

public sealed record StaffTrendPointDto(string Label, decimal Revenue);

public sealed record StaffPerformanceDto(
    Guid BranchId,
    decimal? AverageSalesTargetPercent,
    decimal? CustomerSatisfaction,
    decimal? TeamAttendancePercent,
    StaffPerformanceRowDto? TopPerformer,
    IReadOnlyList<StaffPerformanceRowDto> Staff,
    IReadOnlyList<StaffTrendPointDto> Trend);

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
