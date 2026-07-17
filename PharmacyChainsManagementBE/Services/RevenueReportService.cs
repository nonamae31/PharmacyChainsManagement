using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public class RevenueReportService : IRevenueReportService
{
    private readonly IInvoiceRepository _invoiceRepository;
    private readonly IReportRepository _reportRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<RevenueReportService> _logger;

    public RevenueReportService(
        IInvoiceRepository invoiceRepository,
        IReportRepository reportRepository,
        IUnitOfWork unitOfWork,
        ILogger<RevenueReportService> logger)
    {
        _invoiceRepository = invoiceRepository;
        _reportRepository = reportRepository;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<RevenueReportResponseDto> GenerateRevenueReportAsync(RevenueReportRequestDto request, Guid generatedByUserId)
    {
        // Sử dụng Stopwatch để log hiệu năng
        var sw = Stopwatch.StartNew();
        _logger.LogInformation("Bắt đầu tính Gross Revenue cho Branch: {BranchId}, từ {FromDate} đến {ToDate}", 
            request.BranchId, request.FromDate, request.ToDate);

        var invoices = await _invoiceRepository.GetPaidInvoicesAsync(request.BranchId, request.FromDate, request.ToDate);
        
        decimal grossRevenue = 0;
        foreach (var invoice in invoices)
        {
            grossRevenue += invoice.TotalAmount;
        }

        var report = new Report
        {
            ReportId = Guid.NewGuid(),
            ReportType = "GrossRevenue",
            FromDate = request.FromDate,
            ToDate = request.ToDate,
            GeneratedBy = generatedByUserId,
            Status = "Completed",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _reportRepository.AddAsync(report);
        await _unitOfWork.SaveChangesAsync(); // Commit vào DB

        sw.Stop();
        // Log hiệu năng theo Serilog
        _logger.LogInformation("Tạo báo cáo doanh thu thành công trong {ElapsedMilliseconds} ms. Gross Revenue: {GrossRevenue}", 
            sw.ElapsedMilliseconds, grossRevenue);

        return new RevenueReportResponseDto
        {
            ReportId = report.ReportId,
            BranchId = request.BranchId,
            FromDate = request.FromDate,
            ToDate = request.ToDate,
            GrossRevenue = grossRevenue,
            GeneratedAt = report.CreatedAt
        };
    }
}
