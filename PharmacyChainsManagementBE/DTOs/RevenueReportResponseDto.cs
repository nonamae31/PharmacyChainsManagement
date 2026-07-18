using System;

namespace PharmacyChainsManagementBE.DTOs;

public class RevenueReportResponseDto
{
    public Guid ReportId { get; set; }
    public Guid BranchId { get; set; }
    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
    public decimal GrossRevenue { get; set; }
    public decimal GrossRevenueGrowth { get; set; }
    public List<RevenueItemDto> Items { get; set; } = new List<RevenueItemDto>();
    public decimal AvgRevenuePerBranch { get; set; }
    public decimal AvgRevenueGrowth { get; set; }
    public string TopBranchName { get; set; } = string.Empty;
    public decimal TopBranchRevenue { get; set; }
    public decimal ForecastQ4 { get; set; }
    public List<RevenueMixItemDto> RevenueMix { get; set; } = new List<RevenueMixItemDto>();
    public List<BranchPerformanceItemDto> BranchPerformance { get; set; } = new List<BranchPerformanceItemDto>();
    public DateTime GeneratedAt { get; set; }
}

public class RevenueItemDto
{
    public string Date { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal? PreviousAmount { get; set; }
}

public class RevenueMixItemDto
{
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal Percentage { get; set; }
}

public class BranchPerformanceItemDto
{
    public string BranchName { get; set; } = string.Empty;
    public decimal RevenueMtd { get; set; }
    public decimal VsPreviousMonth { get; set; }
    public decimal OperatingCosts { get; set; }
    public decimal NetMargin { get; set; }
    public string Status { get; set; } = string.Empty;
}
