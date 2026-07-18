using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Models;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Services;

public class RevenueReportService : IRevenueReportService
{
    private readonly IInvoiceRepository _invoiceRepository;
    private readonly IReportRepository _reportRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<RevenueReportService> _logger;
    private readonly PharmacyDbContext _dbContext;

    public RevenueReportService(
        IInvoiceRepository invoiceRepository,
        IReportRepository reportRepository,
        IUnitOfWork unitOfWork,
        ILogger<RevenueReportService> logger,
        PharmacyDbContext dbContext)
    {
        _invoiceRepository = invoiceRepository;
        _reportRepository = reportRepository;
        _unitOfWork = unitOfWork;
        _logger = logger;
        _dbContext = dbContext;
    }

    public async Task<RevenueReportResponseDto> GenerateRevenueReportAsync(RevenueReportRequestDto request, Guid generatedByUserId)
    {
        // Sử dụng Stopwatch để log hiệu năng
        var sw = Stopwatch.StartNew();
        _logger.LogInformation("Bắt đầu tính Gross Revenue cho Branch: {BranchId}, từ {FromDate} đến {ToDate}", 
            request.BranchId, request.FromDate, request.ToDate);

        int duration = request.ToDate.DayNumber - request.FromDate.DayNumber + 1;
        var prevFromDate = request.FromDate.AddDays(-duration);
        var prevToDate = request.ToDate.AddDays(-duration);

        var currentDailyRevenue = await _dbContext.Invoices
            .Where(i => (i.PaymentStatus.ToUpper() == "PAID" || i.PaymentStatus == "Paid") && i.InvoiceDate >= request.FromDate && i.InvoiceDate <= request.ToDate && (request.BranchId == Guid.Empty || i.BranchId == request.BranchId))
            .GroupBy(i => i.InvoiceDate)
            .Select(g => new { Date = g.Key, Amount = g.Sum(i => i.TotalAmount) })
            .ToListAsync();
            
        var prevDailyRevenue = await _dbContext.Invoices
            .Where(i => (i.PaymentStatus.ToUpper() == "PAID" || i.PaymentStatus == "Paid") && i.InvoiceDate >= prevFromDate && i.InvoiceDate <= prevToDate && (request.BranchId == Guid.Empty || i.BranchId == request.BranchId))
            .GroupBy(i => i.InvoiceDate)
            .Select(g => new { Date = g.Key, Amount = g.Sum(i => i.TotalAmount) })
            .ToListAsync();
            
        decimal grossRevenue = currentDailyRevenue.Sum(d => d.Amount);
        decimal prevGrossRevenue = prevDailyRevenue.Sum(d => d.Amount);
        decimal grossRevenueGrowth = prevGrossRevenue == 0 ? 100m : Math.Round((grossRevenue - prevGrossRevenue) / prevGrossRevenue * 100m, 2);

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

        var invoicesByDate = new List<RevenueItemDto>();
        for (int i = 0; i < duration; i++)
        {
            var currDate = request.FromDate.AddDays(i);
            var prevDate = prevFromDate.AddDays(i);
            invoicesByDate.Add(new RevenueItemDto
            {
                Date = currDate.ToString("MMM dd"),
                Amount = currentDailyRevenue.FirstOrDefault(d => d.Date == currDate)?.Amount ?? 0,
                PreviousAmount = prevDailyRevenue.FirstOrDefault(d => d.Date == prevDate)?.Amount ?? 0
            });
        }
                                     
        var branchStats = await _dbContext.Invoices
            .Where(i => (i.PaymentStatus.ToUpper() == "PAID" || i.PaymentStatus == "Paid") && i.InvoiceDate >= request.FromDate && i.InvoiceDate <= request.ToDate && (request.BranchId == Guid.Empty || i.BranchId == request.BranchId))
            .GroupBy(i => new { i.BranchId, i.Branch.BranchName })
            .Select(g => new { BranchId = g.Key.BranchId, BranchName = g.Key.BranchName, Revenue = g.Sum(i => i.TotalAmount) })
            .ToListAsync();

        var prevBranchStats = await _dbContext.Invoices
            .Where(i => (i.PaymentStatus.ToUpper() == "PAID" || i.PaymentStatus == "Paid") && i.InvoiceDate >= prevFromDate && i.InvoiceDate <= prevToDate && (request.BranchId == Guid.Empty || i.BranchId == request.BranchId))
            .GroupBy(i => i.BranchId)
            .Select(g => new { BranchId = g.Key, Revenue = g.Sum(i => i.TotalAmount) })
            .ToListAsync();
            
        var branchCogs = await _dbContext.InvoiceDetails
            .Where(d => (d.Invoice.PaymentStatus.ToUpper() == "PAID" || d.Invoice.PaymentStatus == "Paid") && d.Invoice.InvoiceDate >= request.FromDate && d.Invoice.InvoiceDate <= request.ToDate && (request.BranchId == Guid.Empty || d.Invoice.BranchId == request.BranchId))
            .GroupBy(d => d.Invoice.BranchId)
            .Select(g => new { BranchId = g.Key, Cogs = g.Sum(d => d.Quantity * d.Medicine.StandardPrice) })
            .ToListAsync();
            
        var invoicesByBranch = new List<BranchPerformanceItemDto>();
        foreach (var stat in branchStats)
        {
            var prevRevenue = prevBranchStats.FirstOrDefault(b => b.BranchId == stat.BranchId)?.Revenue ?? 0;
            var cogs = branchCogs.FirstOrDefault(b => b.BranchId == stat.BranchId)?.Cogs ?? 0;
            var vsPrev = prevRevenue == 0 ? 100m : Math.Round((stat.Revenue - prevRevenue) / prevRevenue * 100m, 2);
            var netMargin = stat.Revenue == 0 ? 0 : Math.Round((stat.Revenue - cogs) / stat.Revenue * 100m, 2);
            var status = netMargin >= 20 ? "STABLE" : (netMargin >= 0 ? "WARNING" : "CRITICAL");
            
            invoicesByBranch.Add(new BranchPerformanceItemDto
            {
                BranchName = stat.BranchName,
                RevenueMtd = stat.Revenue,
                VsPreviousMonth = vsPrev,
                OperatingCosts = cogs,
                NetMargin = netMargin,
                Status = status
            });
        }
        invoicesByBranch = invoicesByBranch.OrderByDescending(b => b.RevenueMtd).ToList();

        var totalBranchesCount = await _dbContext.Branches.CountAsync();
        decimal avgRevenuePerBranch = totalBranchesCount > 0 ? Math.Round(grossRevenue / totalBranchesCount, 2) : 0;
        string topBranchName = invoicesByBranch.FirstOrDefault()?.BranchName ?? "";
        decimal topBranchRevenue = invoicesByBranch.FirstOrDefault()?.RevenueMtd ?? 0;

        var categoryStats = await _dbContext.InvoiceDetails
            .Where(d => (d.Invoice.PaymentStatus.ToUpper() == "PAID" || d.Invoice.PaymentStatus == "Paid") && d.Invoice.InvoiceDate >= request.FromDate && d.Invoice.InvoiceDate <= request.ToDate && (request.BranchId == Guid.Empty || d.Invoice.BranchId == request.BranchId))
            .GroupBy(d => d.Medicine.Category)
            .Select(g => new { Category = g.Key, Amount = g.Sum(d => d.LineTotal) })
            .ToListAsync();
            
        var rawRevenueMix = categoryStats.Select(c => new RevenueMixItemDto
        {
            Category = string.IsNullOrEmpty(c.Category) ? "Other" : c.Category,
            Amount = c.Amount,
            Percentage = 0 // Tạm thời để 0, sẽ tính lại sau khi gộp
        }).ToList();

        // Gộp các category trùng lặp (ví dụ null và "")
        var groupedMix = rawRevenueMix.GroupBy(r => r.Category).Select(g => new RevenueMixItemDto 
        {
            Category = g.Key,
            Amount = g.Sum(r => r.Amount),
            Percentage = 0
        }).ToList();

        // Thêm phần doanh thu chưa phân loại (Invoices không có InvoiceDetails) vào "Other"
        decimal totalCategorized = groupedMix.Sum(m => m.Amount);
        if (totalCategorized < grossRevenue)
        {
            var otherItem = groupedMix.FirstOrDefault(m => m.Category == "Other");
            if (otherItem != null)
            {
                otherItem.Amount += (grossRevenue - totalCategorized);
            }
            else
            {
                groupedMix.Add(new RevenueMixItemDto
                {
                    Category = "Other",
                    Amount = grossRevenue - totalCategorized,
                    Percentage = 0
                });
            }
        }

        // Tính lại phần trăm cho tất cả sau khi đã gộp
        foreach (var item in groupedMix)
        {
            item.Percentage = grossRevenue == 0 ? 0 : Math.Round(item.Amount / grossRevenue * 100m, 2);
        }

        var revenueMix = groupedMix.OrderByDescending(r => r.Amount).ToList();

        return new RevenueReportResponseDto
        {
            ReportId = report.ReportId,
            BranchId = request.BranchId,
            FromDate = request.FromDate,
            ToDate = request.ToDate,
            GrossRevenue = grossRevenue,
            GrossRevenueGrowth = grossRevenueGrowth,
            Items = invoicesByDate,
            AvgRevenuePerBranch = avgRevenuePerBranch,
            AvgRevenueGrowth = grossRevenueGrowth,
            TopBranchName = topBranchName,
            TopBranchRevenue = topBranchRevenue,
            ForecastQ4 = grossRevenue * 3,
            RevenueMix = revenueMix,
            BranchPerformance = invoicesByBranch,
            GeneratedAt = report.CreatedAt
        };
    }
}
