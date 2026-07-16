using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public static class BranchManagerDataService
{
    private const string ActiveStatus = "ACTIVE";
    private const string PaidStatus = "PAID";
    private const string CancelledStatus = "CANCELLED";
    private const string StaffRoleCode = "STAFF";
    private const string PendingStatus = "PENDING";
    private const string ApprovedStatus = "APPROVED";
    private const string DailyRevenueAction = "DAILY_REVENUE_CONFIRMED";

    public static async Task<Guid?> ResolveAssignedBranchIdAsync(
        PharmacyDbContext dbContext,
        Guid managerId,
        CancellationToken cancellationToken)
    {
        return await dbContext.Users
            .AsNoTracking()
            .Where(user => user.UserId == managerId && user.Status == ActiveStatus)
            .Select(user => user.BranchId)
            .SingleOrDefaultAsync(cancellationToken);
    }

    public static async Task<BranchDashboardDto?> GetDashboardAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        CancellationToken cancellationToken)
    {
        var branch = await dbContext.Branches
            .AsNoTracking()
            .SingleOrDefaultAsync(item => item.BranchId == branchId, cancellationToken);
        if (branch is null)
        {
            return null;
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var trendStart = today.AddDays(-29);
        var invoices = await dbContext.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.BranchId == branchId
                && invoice.InvoiceDate >= trendStart
                && invoice.InvoiceDate <= today
                && invoice.PaymentStatus == PaidStatus
                && invoice.Status != CancelledStatus)
            .ToListAsync(cancellationToken);

        var todayRevenue = invoices.Where(invoice => invoice.InvoiceDate == today).Sum(invoice => invoice.TotalAmount);
        var previousRevenue = invoices.Where(invoice => invoice.InvoiceDate == today.AddDays(-1)).Sum(invoice => invoice.TotalAmount);
        var revenueChange = previousRevenue == 0
            ? (todayRevenue > 0 ? 100m : 0m)
            : Math.Round((todayRevenue - previousRevenue) / previousRevenue * 100m, 1);

        var staff = await dbContext.Users
            .AsNoTracking()
            .Include(user => user.Role)
            .Where(user => user.BranchId == branchId && user.Role.RoleCode == StaffRoleCode)
            .ToListAsync(cancellationToken);
        var activeStaff = staff.Count(user => user.Status == ActiveStatus);

        var inventory = await dbContext.Inventories
            .AsNoTracking()
            .Include(item => item.Medicine)
            .Include(item => item.Batch)
            .Where(item => item.BranchId == branchId && item.Status == ActiveStatus)
            .ToListAsync(cancellationToken);
        var alerts = inventory.Where(item => item.QuantityOnHand <= item.SafetyStockLevel).ToList();

        var inventoryHealth = inventory.Count == 0
            ? 100m
            : (inventory.Count - alerts.Count) * 100m / inventory.Count;
        var staffHealth = staff.Count == 0 ? 0m : activeStaff * 100m / staff.Count;
        var revenueHealth = previousRevenue == 0
            ? (todayRevenue > 0 ? 100m : 0m)
            : Math.Clamp(todayRevenue / previousRevenue * 100m, 0m, 100m);
        var efficiency = Math.Round(inventoryHealth * 0.5m + staffHealth * 0.25m + revenueHealth * 0.25m, 1);

        var staffSales = invoices
            .GroupBy(invoice => invoice.StaffId)
            .ToDictionary(group => group.Key, group => group.Sum(invoice => invoice.TotalAmount));
        var topStaff = staff
            .Where(item => item.Status == ActiveStatus)
            .Select(item => new DashboardStaffDto(
                item.UserId,
                item.FullName,
                item.Role.RoleName,
                staffSales.GetValueOrDefault(item.UserId)))
            .OrderByDescending(item => item.SalesRevenue)
            .ThenBy(item => item.FullName)
            .Take(3)
            .ToList();

        var inventoryAlerts = alerts
            .GroupBy(item => new
            {
                item.MedicineId,
                item.Medicine.MedicineName,
                item.Medicine.Category
            })
            .Select(group =>
            {
                var currentStock = group.Sum(item => item.QuantityOnHand);
                var reorderPoint = group.Sum(item => item.SafetyStockLevel);
                return new DashboardInventoryDto(
                    group.Key.MedicineId,
                    group.Select(item => item.Batch.BatchNumber).FirstOrDefault() ?? group.Key.MedicineId.ToString("N")[..10],
                    group.Key.MedicineName,
                    group.Key.Category ?? "Uncategorized",
                    currentStock,
                    reorderPoint,
                    GetInventoryStatus(currentStock, reorderPoint));
            })
            .OrderBy(item => item.CurrentStock - item.ReorderPoint)
            .Take(5)
            .ToList();

        return new BranchDashboardDto(
            branch.BranchId,
            branch.BranchName,
            new DashboardMetricDto(todayRevenue, revenueChange, activeStaff, staff.Count, alerts.Count, efficiency),
            BuildDailyRevenueTrend(invoices, trendStart, today),
            topStaff,
            inventoryAlerts);
    }

    public static async Task<BranchRevenueDto> GetRevenueAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken)
    {
        var invoices = await dbContext.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.BranchId == branchId
                && invoice.InvoiceDate >= fromDate
                && invoice.InvoiceDate <= toDate
                && invoice.PaymentStatus == PaidStatus
                && invoice.Status != CancelledStatus)
            .ToListAsync(cancellationToken);
        var invoiceIds = invoices.Select(invoice => invoice.InvoiceId).ToList();
        var details = await dbContext.InvoiceDetails
            .AsNoTracking()
            .Include(detail => detail.Medicine)
            .Where(detail => invoiceIds.Contains(detail.InvoiceId))
            .ToListAsync(cancellationToken);

        var totalRevenue = invoices.Sum(invoice => invoice.TotalAmount);
        var categoryRevenue = details
            .GroupBy(detail => detail.Medicine.Category ?? "Uncategorized")
            .Select(group => new CategoryRevenueDto(
                group.Key,
                group.Sum(detail => detail.LineTotal),
                totalRevenue == 0m ? 0m : Math.Round(group.Sum(detail => detail.LineTotal) / totalRevenue * 100m, 1)))
            .OrderByDescending(item => item.Revenue)
            .ToList();

        var blocks = new[]
        {
            new { Label = "08:00 - 10:00 (Opening)", Start = 8, End = 11 },
            new { Label = "11:00 - 14:00 (Peak Lunch)", Start = 11, End = 15 },
            new { Label = "15:00 - 17:00 (Afternoon)", Start = 15, End = 18 },
            new { Label = "18:00 - 21:00 (Evening Rush)", Start = 18, End = 22 }
        };
        var performance = blocks.Select(block =>
        {
            var blockInvoices = invoices
                .Where(invoice => invoice.CreatedAt.Hour >= block.Start && invoice.CreatedAt.Hour < block.End)
                .ToList();
            var revenue = blockInvoices.Sum(invoice => invoice.TotalAmount);
            var status = blockInvoices.Count switch
            {
                >= 100 => "Critical Load",
                >= 60 => "High Traffic",
                _ => "Normal"
            };
            return new TimeBlockPerformanceDto(
                block.Label,
                blockInvoices.Count,
                revenue,
                blockInvoices.Count == 0 ? 0m : Math.Round(revenue / blockInvoices.Count, 2),
                status);
        }).ToList();

        return new BranchRevenueDto(
            branchId,
            fromDate,
            toDate,
            totalRevenue,
            invoices.Count == 0 ? 0m : Math.Round(totalRevenue / invoices.Count, 2),
            invoices.Count,
            null,
            BuildDailyRevenueTrend(invoices, fromDate, toDate),
            categoryRevenue,
            performance);
    }

    public static async Task<StaffPerformanceDto> GetStaffPerformanceAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly fromDate,
        DateOnly toDate,
        string? search,
        CancellationToken cancellationToken)
    {
        var staff = await dbContext.Users
            .AsNoTracking()
            .Include(user => user.Role)
            .Where(user => user.BranchId == branchId && user.Role.RoleCode == StaffRoleCode)
            .ToListAsync(cancellationToken);
        if (!string.IsNullOrWhiteSpace(search))
        {
            staff = staff.Where(item => item.FullName.Contains(search, StringComparison.OrdinalIgnoreCase)
                || item.Email.Contains(search, StringComparison.OrdinalIgnoreCase)).ToList();
        }

        var staffIds = staff.Select(item => item.UserId).ToList();
        var invoices = await dbContext.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.BranchId == branchId
                && staffIds.Contains(invoice.StaffId)
                && invoice.InvoiceDate >= fromDate
                && invoice.InvoiceDate <= toDate
                && invoice.PaymentStatus == PaidStatus
                && invoice.Status != CancelledStatus)
            .ToListAsync(cancellationToken);
        var revenueByStaff = invoices
            .GroupBy(invoice => invoice.StaffId)
            .ToDictionary(group => group.Key, group => group.Sum(invoice => invoice.TotalAmount));
        var rows = staff.Select(item =>
        {
            var revenue = revenueByStaff.GetValueOrDefault(item.UserId);
            return new StaffPerformanceRowDto(
                item.UserId,
                item.FullName,
                item.Role.RoleName,
                revenue,
                null,
                null,
                null,
                null,
                null);
        })
        .OrderByDescending(item => item.SalesRevenue)
        .ThenBy(item => item.FullName)
        .ToList();

        var trendStart = toDate.AddMonths(-5);
        var trendInvoices = await dbContext.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.BranchId == branchId
                && invoice.InvoiceDate >= trendStart
                && invoice.InvoiceDate <= toDate
                && invoice.PaymentStatus == PaidStatus
                && invoice.Status != CancelledStatus)
            .ToListAsync(cancellationToken);
        var trend = Enumerable.Range(0, 6)
            .Select(index => new DateOnly(trendStart.Year, trendStart.Month, 1).AddMonths(index))
            .Select(month => new StaffTrendPointDto(
                month.ToString("MMM yyyy"),
                trendInvoices.Where(invoice => invoice.InvoiceDate.Year == month.Year && invoice.InvoiceDate.Month == month.Month)
                    .Sum(invoice => invoice.TotalAmount)))
            .ToList();

        return new StaffPerformanceDto(
            branchId,
            null,
            null,
            null,
            rows.FirstOrDefault(),
            rows,
            trend);
    }

    public static async Task<BranchInventoryDto> GetInventoryAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        string? search,
        string? category,
        string? status,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var inventory = await dbContext.Inventories
            .AsNoTracking()
            .Include(item => item.Medicine)
            .Include(item => item.Batch)
                .ThenInclude(batch => batch.Supplier)
            .Where(item => item.BranchId == branchId && item.Status == ActiveStatus)
            .ToListAsync(cancellationToken);

        var rows = inventory
            .GroupBy(item => new
            {
                item.MedicineId,
                item.Medicine.MedicineName,
                item.Medicine.Category,
                item.Medicine.StandardPrice
            })
            .Select(group =>
            {
                var currentStock = group.Sum(item => item.QuantityOnHand);
                var reorderPoint = group.Sum(item => item.SafetyStockLevel);
                return new BranchInventoryRowDto(
                    group.Key.MedicineId,
                    group.Select(item => item.Batch.BatchNumber).FirstOrDefault() ?? group.Key.MedicineId.ToString("N")[..10],
                    group.Key.MedicineName,
                    group.Key.Category ?? "Uncategorized",
                    currentStock,
                    reorderPoint,
                    GetInventoryStatus(currentStock, reorderPoint),
                    string.Join(", ", group.Select(item => item.Batch.Supplier.SupplierName).Distinct()),
                    group.Max(item => item.UpdatedAt),
                    currentStock * group.Key.StandardPrice);
            })
            .ToList();

        var categories = rows.Select(item => item.Category).Distinct().OrderBy(item => item).ToList();
        var criticalStock = rows.Count(item => item.Status != "In Stock");
        var inventoryValue = rows.Sum(item => item.InventoryValue);
        if (!string.IsNullOrWhiteSpace(search))
        {
            rows = rows.Where(item => item.MedicineName.Contains(search, StringComparison.OrdinalIgnoreCase)
                || item.Sku.Contains(search, StringComparison.OrdinalIgnoreCase)).ToList();
        }
        if (!string.IsNullOrWhiteSpace(category) && !category.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            rows = rows.Where(item => item.Category.Equals(category, StringComparison.OrdinalIgnoreCase)).ToList();
        }
        if (!string.IsNullOrWhiteSpace(status) && !status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            rows = rows.Where(item => item.Status.Equals(status, StringComparison.OrdinalIgnoreCase)).ToList();
        }

        var inTransit = await dbContext.StockTransferDetails
            .AsNoTracking()
            .Where(detail => detail.Transfer.ToBranchId == branchId
                && (detail.Transfer.TransferStatus == PendingStatus || detail.Transfer.TransferStatus == ApprovedStatus))
            .SumAsync(detail => (int?)detail.Quantity, cancellationToken) ?? 0;
        var totalRecords = rows.Count;
        var items = rows
            .OrderBy(item => item.CurrentStock - item.ReorderPoint)
            .ThenBy(item => item.MedicineName)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        return new BranchInventoryDto(
            branchId,
            inventory.Select(item => item.MedicineId).Distinct().Count(),
            criticalStock,
            inTransit,
            inventoryValue,
            page,
            pageSize,
            totalRecords,
            categories,
            items);
    }

    public static async Task<DailyRevenueConfirmationDto> ConfirmDailyRevenueAsync(
        PharmacyDbContext dbContext,
        Guid managerId,
        Guid branchId,
        ConfirmDailyRevenueRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var payments = await dbContext.PaymentTransactions
            .AsNoTracking()
            .Where(payment => payment.Invoice.BranchId == branchId
                && payment.Invoice.InvoiceDate == today
                && payment.PaymentStatus == PaidStatus)
            .ToListAsync(cancellationToken);
        var systemAmount = payments.Sum(payment => payment.Amount);
        var actualAmount = request.ActualCash + request.ActualBankTransfer + request.ActualOther;
        var difference = actualAmount - systemAmount;
        var confirmationId = Guid.NewGuid();
        var confirmedAt = DateTime.UtcNow;

        var auditPayload = JsonSerializer.Serialize(new
        {
            confirmationId,
            revenueDate = today,
            systemAmount,
            request.ActualCash,
            request.ActualBankTransfer,
            request.ActualOther,
            actualAmount,
            difference,
            request.DifferenceReason,
            confirmedAt
        });
        dbContext.AuditLogs.Add(new AuditLog
        {
            AuditId = confirmationId,
            ActorId = managerId,
            EntityName = "BRANCH_DAILY_REVENUE",
            EntityId = branchId,
            Action = DailyRevenueAction,
            NewValue = auditPayload,
            CreatedAt = confirmedAt
        });
        await dbContext.SaveChangesAsync(cancellationToken);

        return new DailyRevenueConfirmationDto(
            confirmationId,
            today,
            systemAmount,
            actualAmount,
            difference,
            difference == 0m,
            confirmedAt);
    }

    private static IReadOnlyList<RevenuePointDto> BuildDailyRevenueTrend(
        IReadOnlyCollection<Invoice> invoices,
        DateOnly fromDate,
        DateOnly toDate)
    {
        var revenueByDate = invoices
            .GroupBy(invoice => invoice.InvoiceDate)
            .ToDictionary(group => group.Key, group => group.Sum(invoice => invoice.TotalAmount));
        var days = toDate.DayNumber - fromDate.DayNumber + 1;
        return Enumerable.Range(0, Math.Max(days, 0))
            .Select(offset => fromDate.AddDays(offset))
            .Select(date => new RevenuePointDto(date, revenueByDate.GetValueOrDefault(date)))
            .ToList();
    }

    private static string GetInventoryStatus(int currentStock, int reorderPoint)
    {
        if (currentStock <= 0)
        {
            return "Out of Stock";
        }

        if (currentStock <= reorderPoint)
        {
            return currentStock <= Math.Max(1, reorderPoint / 2) ? "Critical" : "Low Stock";
        }

        return "In Stock";
    }
}
