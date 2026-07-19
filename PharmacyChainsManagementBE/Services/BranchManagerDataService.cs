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
    private const string CompletedStatus = "COMPLETED";
    private const string CancelledStatus = "CANCELLED";
    private const string StaffRoleCode = "STAFF";
    private const string PendingStatus = "PENDING";
    private const string ApprovedStatus = "APPROVED";
    private const string DailyRevenueAction = "DAILY_REVENUE_CONFIRMED";
    private const string DailyRevenueEntity = "BRANCH_DAILY_REVENUE";
    private const string ScheduledShiftStatus = "SCHEDULED";
    private static readonly TimeZoneInfo VietnamTimeZone = ResolveVietnamTimeZone();
    private static readonly JsonSerializerOptions AuditJsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

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
        string trendPeriod,
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
        var trendStart = trendPeriod.Trim().ToLowerInvariant() switch
        {
            "quarter" => today.AddDays(-89),
            "year" => today.AddDays(-364),
            _ => today.AddDays(-29)
        };
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
        var inventoryRows = inventory
            .GroupBy(item => new
            {
                item.MedicineId,
                item.Medicine.MedicineName,
                item.Medicine.Category
            })
            .Select(group => new
            {
                group.Key.MedicineId,
                group.Key.MedicineName,
                Category = group.Key.Category ?? "Uncategorized",
                Sku = group.Select(item => item.Batch.BatchNumber).FirstOrDefault()
                    ?? group.Key.MedicineId.ToString("N")[..10],
                CurrentStock = group.Sum(item => item.QuantityOnHand),
                ReorderPoint = group.Sum(item => item.SafetyStockLevel)
            })
            .ToList();
        var alerts = inventoryRows
            .Where(item => item.CurrentStock <= item.ReorderPoint)
            .ToList();

        var inventoryHealth = inventoryRows.Count == 0
            ? 100m
            : (inventoryRows.Count - alerts.Count) * 100m / inventoryRows.Count;
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
            .Select(item => new DashboardInventoryDto(
                item.MedicineId,
                item.Sku,
                item.MedicineName,
                item.Category,
                item.CurrentStock,
                item.ReorderPoint,
                GetInventoryStatus(item.CurrentStock, item.ReorderPoint)))
            .OrderBy(item => item.CurrentStock - item.ReorderPoint)
            .Take(5)
            .ToList();
        var todayRevenueConfirmation = await GetDailyRevenueConfirmationAsync(
            dbContext,
            branchId,
            today,
            cancellationToken);

        return new BranchDashboardDto(
            branch.BranchId,
            branch.BranchName,
            new DashboardMetricDto(todayRevenue, revenueChange, activeStaff, staff.Count, alerts.Count, efficiency),
            BuildDailyRevenueTrend(invoices, trendStart, today),
            topStaff,
            inventoryAlerts,
            todayRevenueConfirmation);
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
        var payments = await dbContext.PaymentTransactions
            .AsNoTracking()
            .Where(payment => invoiceIds.Contains(payment.InvoiceId)
                && (payment.PaymentStatus.ToUpper() == PaidStatus
                    || payment.PaymentStatus.ToUpper() == CompletedStatus))
            .ToListAsync(cancellationToken);

        var totalRevenue = invoices.Sum(invoice => invoice.TotalAmount);
        var effectivePayments = new List<(string PaymentMethod, decimal Amount)>();
        foreach (var invoice in invoices)
        {
            var remainingAmount = invoice.TotalAmount;
            var invoicePayments = payments
                .Where(payment => payment.InvoiceId == invoice.InvoiceId)
                .OrderByDescending(payment => payment.PaymentDate ?? payment.CreatedAt)
                .ThenByDescending(payment => payment.CreatedAt);
            foreach (var payment in invoicePayments)
            {
                if (remainingAmount <= 0m)
                {
                    break;
                }

                var appliedAmount = Math.Min(Math.Max(payment.Amount, 0m), remainingAmount);
                if (appliedAmount == 0m)
                {
                    continue;
                }

                effectivePayments.Add((payment.PaymentMethod.Trim().ToUpperInvariant(), appliedAmount));
                remainingAmount -= appliedAmount;
            }
        }

        var recordedPaymentTotal = effectivePayments.Sum(payment => payment.Amount);
        var paymentMethods = effectivePayments
            .GroupBy(payment => payment.PaymentMethod)
            .Select(group => new PaymentMethodRevenueDto(
                group.Key,
                group.Count(),
                group.Sum(payment => payment.Amount),
                recordedPaymentTotal == 0m
                    ? 0m
                    : Math.Round(group.Sum(payment => payment.Amount) / recordedPaymentTotal * 100m, 1)))
            .OrderByDescending(item => item.Revenue)
            .ThenBy(item => item.PaymentMethod)
            .ToList();
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
            new { Label = "08:00 - 12:00 (Morning)", Start = 8, End = 12 },
            new { Label = "12:00 - 17:00 (Afternoon)", Start = 12, End = 17 },
            new { Label = "17:00 - 22:00 (Evening)", Start = 17, End = 22 }
        };
        var performance = blocks.Select(block =>
        {
            var blockInvoices = invoices
                .Where(invoice =>
                {
                    var localHour = ConvertToVietnamTime(invoice.CreatedAt).Hour;
                    return localHour >= block.Start && localHour < block.End;
                })
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
            invoices.Count,
            null,
            BuildDailyRevenueTrend(invoices, fromDate, toDate),
            categoryRevenue,
            performance,
            paymentMethods);
    }

    public static async Task<StaffPerformanceDto> GetStaffPerformanceAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly fromDate,
        DateOnly toDate,
        string? search,
        string? status,
        string sort,
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
        if (!string.IsNullOrWhiteSpace(status) && !status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            staff = staff.Where(item => item.Status.Equals(status, StringComparison.OrdinalIgnoreCase)).ToList();
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
        var assessments = await dbContext.StaffAssessments
            .AsNoTracking()
            .Where(item => item.BranchId == branchId && staffIds.Contains(item.StaffId))
            .OrderByDescending(item => item.AssessmentDate)
            .ThenByDescending(item => item.CreatedAt)
            .ToListAsync(cancellationToken);
        var latestAssessmentByStaff = assessments
            .GroupBy(item => item.StaffId)
            .ToDictionary(group => group.Key, group => group.First());
        var rows = staff.Select(item =>
        {
            var revenue = revenueByStaff.GetValueOrDefault(item.UserId);
            latestAssessmentByStaff.TryGetValue(item.UserId, out var assessment);
            decimal? targetProgress = assessment is null || assessment.SalesTarget == 0m
                ? null
                : Math.Round(revenue / assessment.SalesTarget * 100m, 1);
            return new StaffPerformanceRowDto(
                item.UserId,
                item.FullName,
                item.Email,
                item.Role.RoleName,
                item.Status,
                revenue,
                assessment?.AssessmentDate,
                assessment?.SalesTarget,
                targetProgress,
                assessment?.CustomerRating,
                assessment?.AttendancePercent,
                assessment?.PerformanceScore);
        })
        .ToList();
        rows = (sort ?? "revenue_desc").Trim().ToLowerInvariant() switch
        {
            "name_asc" => rows.OrderBy(item => item.FullName).ToList(),
            "performance_desc" => rows.OrderByDescending(item => item.PerformanceScore ?? -1m)
                .ThenByDescending(item => item.SalesRevenue).ToList(),
            _ => rows.OrderByDescending(item => item.SalesRevenue).ThenBy(item => item.FullName).ToList()
        };

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
            rows.Any(item => item.TargetProgressPercent.HasValue)
                ? rows.Where(item => item.TargetProgressPercent.HasValue).Average(item => item.TargetProgressPercent!.Value)
                : null,
            rows.Any(item => item.CustomerRating.HasValue)
                ? rows.Where(item => item.CustomerRating.HasValue).Average(item => item.CustomerRating!.Value)
                : null,
            rows.Any(item => item.AttendancePercent.HasValue)
                ? rows.Where(item => item.AttendancePercent.HasValue).Average(item => item.AttendancePercent!.Value)
                : null,
            rows.OrderByDescending(item => item.SalesRevenue).FirstOrDefault(),
            rows,
            trend,
            assessments
                .Take(5)
                .Join(staff, assessment => assessment.StaffId, user => user.UserId,
                    (assessment, user) => new StaffFeedbackDto(
                        assessment.AssessmentId,
                        assessment.StaffId,
                        user.FullName,
                        assessment.AssessmentDate,
                        assessment.PerformanceScore,
                        assessment.Notes ?? string.Empty))
                .ToList());
    }

    public static async Task<BranchStaffDto?> UpdateStaffStatusAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        Guid staffId,
        string status,
        CancellationToken cancellationToken)
    {
        var staff = await dbContext.Users.SingleOrDefaultAsync(
            user => user.UserId == staffId && user.BranchId == branchId && user.Role.RoleCode == StaffRoleCode,
            cancellationToken);
        if (staff is null)
        {
            return null;
        }

        staff.Status = status;
        staff.UpdatedAt = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);

        return new BranchStaffDto(staff.UserId, staff.FullName, staff.Email, staff.Phone, staff.Status, staff.UpdatedAt);
    }

    public static async Task<IReadOnlyList<StaffShiftDto>> GetStaffShiftsAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly date,
        CancellationToken cancellationToken)
    {
        var staffNames = await dbContext.Users
            .AsNoTracking()
            .Where(user => user.BranchId == branchId && user.Role.RoleCode == StaffRoleCode)
            .ToDictionaryAsync(user => user.UserId, user => user.FullName, cancellationToken);
        var staffIds = staffNames.Keys.ToList();
        var shifts = await dbContext.StaffShifts
            .AsNoTracking()
            .Where(shift => shift.BranchId == branchId && shift.ShiftDate == date && staffIds.Contains(shift.StaffId))
            .OrderBy(shift => shift.StartTime)
            .ToListAsync(cancellationToken);

        return shifts.Select(shift => new StaffShiftDto(
            shift.ShiftId,
            shift.StaffId,
            staffNames.GetValueOrDefault(shift.StaffId, string.Empty),
            shift.ShiftDate,
            shift.StartTime,
            shift.EndTime,
            shift.Status,
            shift.Notes,
            shift.UpdatedAt)).ToList();
    }

    public static async Task<StaffShiftDto?> UpsertStaffShiftAsync(
        PharmacyDbContext dbContext,
        Guid managerId,
        Guid branchId,
        UpsertStaffShiftRequestDto request,
        CancellationToken cancellationToken)
    {
        var staff = await dbContext.Users
            .AsNoTracking()
            .Include(user => user.Role)
            .SingleOrDefaultAsync(user => user.UserId == request.StaffId
                && user.BranchId == branchId
                && user.Role.RoleCode == StaffRoleCode
                && user.Status == ActiveStatus,
                cancellationToken);
        if (staff is null)
        {
            return null;
        }

        var normalizedStatus = request.Status.Trim().ToUpperInvariant();
        var now = DateTime.UtcNow;
        var shift = await dbContext.StaffShifts.SingleOrDefaultAsync(
            item => item.BranchId == branchId
                && item.StaffId == request.StaffId
                && item.ShiftDate == request.ShiftDate,
            cancellationToken);
        if (shift is null && normalizedStatus != ScheduledShiftStatus)
        {
            return null;
        }

        if (shift is null)
        {
            shift = new StaffShift
            {
                ShiftId = Guid.NewGuid(),
                BranchId = branchId,
                StaffId = request.StaffId,
                ShiftDate = request.ShiftDate,
                CreatedBy = managerId,
                CreatedAt = now
            };
            dbContext.StaffShifts.Add(shift);
        }

        if (normalizedStatus == ScheduledShiftStatus)
        {
            shift.StartTime = request.StartTime;
            shift.EndTime = request.EndTime;
        }
        shift.Status = normalizedStatus;
        shift.Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim();
        shift.UpdatedAt = now;
        await dbContext.SaveChangesAsync(cancellationToken);

        return new StaffShiftDto(
            shift.ShiftId,
            shift.StaffId,
            staff.FullName,
            shift.ShiftDate,
            shift.StartTime,
            shift.EndTime,
            shift.Status,
            shift.Notes,
            shift.UpdatedAt);
    }

    public static async Task<StaffAssessmentDto?> CreateStaffAssessmentAsync(
        PharmacyDbContext dbContext,
        Guid managerId,
        Guid branchId,
        CreateStaffAssessmentRequestDto request,
        CancellationToken cancellationToken)
    {
        var isBranchStaff = await dbContext.Users.AnyAsync(user => user.UserId == request.StaffId
            && user.BranchId == branchId
            && user.Role.RoleCode == StaffRoleCode,
            cancellationToken);
        if (!isBranchStaff)
        {
            return null;
        }

        var assessment = new StaffAssessment
        {
            AssessmentId = Guid.NewGuid(),
            BranchId = branchId,
            StaffId = request.StaffId,
            AssessedBy = managerId,
            AssessmentDate = request.AssessmentDate,
            SalesTarget = request.SalesTarget,
            CustomerRating = request.CustomerRating,
            AttendancePercent = request.AttendancePercent,
            PerformanceScore = request.PerformanceScore,
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            CreatedAt = DateTime.UtcNow
        };
        dbContext.StaffAssessments.Add(assessment);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new StaffAssessmentDto(
            assessment.AssessmentId,
            assessment.StaffId,
            assessment.AssessmentDate,
            assessment.SalesTarget,
            assessment.CustomerRating,
            assessment.AttendancePercent,
            assessment.PerformanceScore,
            assessment.Notes,
            assessment.CreatedAt);
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

    public static async Task<ShipmentOptionsDto> GetShipmentOptionsAsync(
        PharmacyDbContext dbContext,
        Guid destinationBranchId,
        CancellationToken cancellationToken)
    {
        var inventory = await dbContext.Inventories
            .AsNoTracking()
            .Include(item => item.Branch)
            .Include(item => item.Medicine)
            .Include(item => item.Batch)
            .Where(item => item.BranchId != destinationBranchId
                && item.Branch.Status == ActiveStatus
                && item.Status == ActiveStatus
                && item.QuantityOnHand > 0
                && item.Batch.Status == ActiveStatus)
            .OrderBy(item => item.Branch.BranchName)
            .ThenBy(item => item.Medicine.MedicineName)
            .ToListAsync(cancellationToken);

        return new ShipmentOptionsDto(
            inventory
                .GroupBy(item => new { item.BranchId, item.Branch.BranchName })
                .Select(group => new TransferSourceBranchDto(group.Key.BranchId, group.Key.BranchName))
                .ToList(),
            inventory.Select(item => new TransferBatchOptionDto(
                item.BranchId,
                item.MedicineId,
                item.BatchId,
                item.Medicine.MedicineName,
                item.Batch.BatchNumber,
                item.QuantityOnHand,
                item.Batch.ExpiryDate)).ToList());
    }

    public static async Task<decimal> GetDailySystemRevenueAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly revenueDate,
        CancellationToken cancellationToken)
    {
        return await dbContext.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.BranchId == branchId
                && invoice.InvoiceDate == revenueDate
                && invoice.PaymentStatus == PaidStatus
                && invoice.Status != CancelledStatus)
            .SumAsync(invoice => (decimal?)invoice.TotalAmount, cancellationToken) ?? 0m;
    }

    public static async Task<DailyRevenueConfirmationDto?> GetDailyRevenueConfirmationAsync(
        PharmacyDbContext dbContext,
        Guid branchId,
        DateOnly revenueDate,
        CancellationToken cancellationToken)
    {
        var dayStart = DateTime.SpecifyKind(
            revenueDate.ToDateTime(TimeOnly.MinValue),
            DateTimeKind.Utc);
        var dayEnd = dayStart.AddDays(1);
        var auditLog = await dbContext.AuditLogs
            .AsNoTracking()
            .Where(log => log.EntityId == branchId
                && log.EntityName == DailyRevenueEntity
                && log.Action == DailyRevenueAction
                && log.CreatedAt >= dayStart
                && log.CreatedAt < dayEnd)
            .OrderBy(log => log.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken);

        return auditLog is null
            ? null
            : MapDailyRevenueConfirmation(auditLog, revenueDate);
    }

    public static async Task<DailyRevenueConfirmationDto?> ConfirmDailyRevenueAsync(
        PharmacyDbContext dbContext,
        Guid managerId,
        Guid branchId,
        ConfirmDailyRevenueRequestDto request,
        CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        await using var transaction = await dbContext.Database.BeginTransactionAsync(
            cancellationToken);
        await dbContext.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM \"BRANCH\" WHERE \"branch_id\" = {branchId} FOR UPDATE",
            cancellationToken);
        if (await GetDailyRevenueConfirmationAsync(
                dbContext,
                branchId,
                today,
                cancellationToken) is not null)
        {
            return null;
        }

        var systemAmount = await GetDailySystemRevenueAsync(
            dbContext,
            branchId,
            today,
            cancellationToken);
        var actualAmount = request.ActualCash + request.ActualBankTransfer + request.ActualOther;
        var difference = actualAmount - systemAmount;
        var differenceReason = string.IsNullOrWhiteSpace(request.DifferenceReason)
            ? null
            : request.DifferenceReason.Trim();
        var confirmationId = Guid.NewGuid();
        var confirmedAt = DateTime.UtcNow;

        var auditPayload = JsonSerializer.Serialize(new
        {
            confirmationId,
            revenueDate = today,
            systemAmount,
            actualCash = request.ActualCash,
            actualBankTransfer = request.ActualBankTransfer,
            actualOther = request.ActualOther,
            actualAmount,
            difference,
            differenceReason,
            confirmedAt
        });
        dbContext.AuditLogs.Add(new AuditLog
        {
            AuditId = confirmationId,
            ActorId = managerId,
            EntityName = DailyRevenueEntity,
            EntityId = branchId,
            Action = DailyRevenueAction,
            NewValue = auditPayload,
            CreatedAt = confirmedAt
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        return new DailyRevenueConfirmationDto(
            confirmationId,
            today,
            systemAmount,
            request.ActualCash,
            request.ActualBankTransfer,
            request.ActualOther,
            actualAmount,
            difference,
            difference == 0m,
            confirmedAt,
            differenceReason);
    }

    private static DailyRevenueConfirmationDto MapDailyRevenueConfirmation(
        AuditLog auditLog,
        DateOnly fallbackRevenueDate)
    {
        DailyRevenueAuditPayload? payload = null;
        if (!string.IsNullOrWhiteSpace(auditLog.NewValue))
        {
            try
            {
                payload = JsonSerializer.Deserialize<DailyRevenueAuditPayload>(
                    auditLog.NewValue,
                    AuditJsonOptions);
            }
            catch (JsonException)
            {
                payload = null;
            }
        }

        var actualCash = payload?.ActualCash ?? 0m;
        var actualBankTransfer = payload?.ActualBankTransfer ?? 0m;
        var actualOther = payload?.ActualOther ?? 0m;
        var actualAmount = payload?.ActualAmount
            ?? actualCash + actualBankTransfer + actualOther;
        var systemAmount = payload?.SystemAmount ?? 0m;
        var difference = payload?.Difference ?? actualAmount - systemAmount;

        return new DailyRevenueConfirmationDto(
            payload?.ConfirmationId ?? auditLog.AuditId,
            payload?.RevenueDate ?? fallbackRevenueDate,
            systemAmount,
            actualCash,
            actualBankTransfer,
            actualOther,
            actualAmount,
            difference,
            difference == 0m,
            payload?.ConfirmedAt ?? auditLog.CreatedAt,
            payload?.DifferenceReason);
    }

    private sealed class DailyRevenueAuditPayload
    {
        public Guid? ConfirmationId { get; init; }
        public DateOnly? RevenueDate { get; init; }
        public decimal? SystemAmount { get; init; }
        public decimal? ActualCash { get; init; }
        public decimal? ActualBankTransfer { get; init; }
        public decimal? ActualOther { get; init; }
        public decimal? ActualAmount { get; init; }
        public decimal? Difference { get; init; }
        public string? DifferenceReason { get; init; }
        public DateTime? ConfirmedAt { get; init; }
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

    private static DateTime ConvertToVietnamTime(DateTime value)
    {
        var utcValue = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
        };
        return TimeZoneInfo.ConvertTimeFromUtc(utcValue, VietnamTimeZone);
    }

    private static TimeZoneInfo ResolveVietnamTimeZone()
    {
        foreach (var timeZoneId in new[] { "Asia/Ho_Chi_Minh", "SE Asia Standard Time" })
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            }
            catch (TimeZoneNotFoundException)
            {
                // Try the platform-specific fallback identifier.
            }
            catch (InvalidTimeZoneException)
            {
                // Try the platform-specific fallback identifier.
            }
        }

        return TimeZoneInfo.CreateCustomTimeZone(
            "UTC+07",
            TimeSpan.FromHours(7),
            "UTC+07",
            "UTC+07");
    }
}
