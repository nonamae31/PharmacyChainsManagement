using System;

namespace PharmacyChainsManagementBE.DTOs;

public class RevenueReportResponseDto
{
    public Guid ReportId { get; set; }
    public Guid BranchId { get; set; }
    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
    public decimal GrossRevenue { get; set; }
    public DateTime GeneratedAt { get; set; }
}
