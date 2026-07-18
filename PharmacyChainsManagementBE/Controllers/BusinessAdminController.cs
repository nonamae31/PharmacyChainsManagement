using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Controllers;

[Authorize(Roles = "BUSINESS_ADMIN")]
[ApiController]
[Route("api/v1/business-admin")]
public class BusinessAdminController : ControllerBase
{
    private readonly PharmacyDbContext _context;

    public BusinessAdminController(PharmacyDbContext context)
    {
        _context = context;
    }

    [HttpGet("branches")]
    public async Task<IActionResult> GetBranches(
        [FromQuery] string? search,
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Branches.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(branch =>
                branch.BranchName.Contains(search) || branch.Address.Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(branch => branch.Status == status);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(branch => branch.BranchName)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(branch => new
            {
                branchId = branch.BranchId,
                branchName = branch.BranchName,
                address = branch.Address,
                phone = branch.Phone,
                latitude = branch.Latitude,
                longitude = branch.Longitude,
                status = branch.Status,
                managerName = branch.Users
                    .Where(user => user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.FullName)
                    .FirstOrDefault(),
                managerEmail = branch.Users
                    .Where(user => user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.Email)
                    .FirstOrDefault(),
                managerJoinedDate = branch.Users
                    .Where(user => user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => (DateTime?)user.CreatedAt)
                    .FirstOrDefault(),
                dailyRevenue = branch.Invoices.Sum(invoice => invoice.TotalAmount),
                staffCount = branch.Users.Count,
                createdAt = branch.CreatedAt,
                updatedAt = branch.UpdatedAt
            })
            .ToListAsync(cancellationToken);

        return Ok(new { items, page, pageSize, totalCount });
    }

    [HttpPost("branches")]
    public async Task<IActionResult> CreateBranch(
        [FromBody] BranchRequest request,
        CancellationToken cancellationToken)
    {
        var validationResult = ValidateBranchRequest(request);
        if (validationResult != null)
        {
            return validationResult;
        }

        var now = DateTime.UtcNow;
        var branch = new Branch
        {
            BranchId = Guid.NewGuid(),
            BranchName = request.BranchName.Trim(),
            Address = request.Address.Trim(),
            Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
            Latitude = request.Latitude.HasValue ? Convert.ToDecimal(request.Latitude.Value) : null,
            Longitude = request.Longitude.HasValue ? Convert.ToDecimal(request.Longitude.Value) : null,
            Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim(),
            CreatedAt = now,
            UpdatedAt = now
        };

        _context.Branches.Add(branch);
        await _context.SaveChangesAsync(cancellationToken);

        return Ok(ToBranchResponse(branch));
    }

    [HttpPut("branches/{branchId:guid}")]
    public async Task<IActionResult> UpdateBranch(
        Guid branchId,
        [FromBody] BranchRequest request,
        CancellationToken cancellationToken)
    {
        var validationResult = ValidateBranchRequest(request);
        if (validationResult != null)
        {
            return validationResult;
        }

        var branch = await _context.Branches
            .FirstOrDefaultAsync(item => item.BranchId == branchId, cancellationToken);
        if (branch == null)
        {
            return NotFound();
        }

        branch.BranchName = request.BranchName.Trim();
        branch.Address = request.Address.Trim();
        branch.Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
        branch.Latitude = request.Latitude.HasValue ? Convert.ToDecimal(request.Latitude.Value) : null;
        branch.Longitude = request.Longitude.HasValue ? Convert.ToDecimal(request.Longitude.Value) : null;
        branch.Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim();
        branch.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return Ok(ToBranchResponse(branch));
    }

    [HttpGet("medicine-statistics")]
    public async Task<IActionResult> GetMedicineStatistics(
        [FromQuery] string? branchId,
        [FromQuery] string? category,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var nearExpiryDate = today.AddDays(30);

        var query = _context.Inventories
            .AsNoTracking()
            .Include(inventory => inventory.Branch)
            .Include(inventory => inventory.Medicine)
            .Include(inventory => inventory.Batch)
            .AsQueryable();

        if (Guid.TryParse(branchId, out var parsedBranchId))
        {
            query = query.Where(inventory => inventory.BranchId == parsedBranchId);
        }

        if (!string.IsNullOrWhiteSpace(category))
        {
            query = query.Where(inventory => inventory.Medicine.Category == category);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(inventory =>
                inventory.Medicine.MedicineName.Contains(search) ||
                inventory.Branch.BranchName.Contains(search));
        }

        var allItems = await query.ToListAsync(cancellationToken);

        var inventoryItems = allItems
            .OrderBy(item => item.Medicine.MedicineName)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(item => new
            {
                medicineId = item.MedicineId,
                medicineName = item.Medicine.MedicineName,
                category = item.Medicine.Category,
                branchName = item.Branch.BranchName,
                batchNumber = item.Batch.BatchNumber,
                quantityOnHand = item.QuantityOnHand,
                safetyStockLevel = item.SafetyStockLevel,
                expiryDate = item.Batch.ExpiryDate.ToDateTime(TimeOnly.MinValue),
                status = item.Status
            })
            .ToList();

        var bestSellingList = await _context.InvoiceDetails
            .AsNoTracking()
            .Include(detail => detail.Medicine)
            .GroupBy(detail => new { detail.MedicineId, detail.Medicine.MedicineName })
            .Select(group => new
            {
                medicineId = group.Key.MedicineId,
                medicineName = group.Key.MedicineName,
                quantitySold = group.Sum(detail => detail.Quantity),
                revenue = group.Sum(detail => detail.LineTotal)
            })
            .OrderByDescending(item => item.quantitySold)
            .Take(10)
            .ToListAsync(cancellationToken);

        var lowStockList = allItems
            .Where(item => item.QuantityOnHand <= item.SafetyStockLevel)
            .Take(10)
            .Select(item => new
            {
                medicineId = item.MedicineId,
                medicineName = item.Medicine.MedicineName,
                category = item.Medicine.Category,
                branchName = item.Branch.BranchName,
                batchNumber = item.Batch.BatchNumber,
                quantityOnHand = item.QuantityOnHand,
                safetyStockLevel = item.SafetyStockLevel,
                expiryDate = item.Batch.ExpiryDate.ToDateTime(TimeOnly.MinValue),
                status = item.Status
            })
            .ToList();

        var nearExpiryList = allItems
            .Where(item => item.Batch.ExpiryDate <= nearExpiryDate)
            .Take(10)
            .Select(item => new
            {
                medicineId = item.MedicineId,
                medicineName = item.Medicine.MedicineName,
                category = item.Medicine.Category,
                branchName = item.Branch.BranchName,
                batchNumber = item.Batch.BatchNumber,
                quantityOnHand = item.QuantityOnHand,
                safetyStockLevel = item.SafetyStockLevel,
                expiryDate = item.Batch.ExpiryDate.ToDateTime(TimeOnly.MinValue),
                status = item.Status
            })
            .ToList();

        var response = new
        {
            generatedAt = DateTime.UtcNow,
            summary = new
            {
                totalMedicines = await _context.Medicines.CountAsync(cancellationToken),
                outOfStockCount = allItems.Count(item => item.QuantityOnHand <= 0),
                lowStockCount = allItems.Count(item => item.QuantityOnHand <= item.SafetyStockLevel),
                nearExpiryCount = allItems.Count(item => item.Batch.ExpiryDate <= nearExpiryDate),
                fulfillmentRate = allItems.Count == 0
                    ? 0
                    : Math.Round(allItems.Count(item => item.QuantityOnHand > 0) * 100.0 / allItems.Count, 2)
            },
            inventoryItems,
            bestSellingList,
            lowStockList,
            nearExpiryList
        };

        return Ok(response);
    }

    [HttpGet("reports/business-analysis")]
    public async Task<IActionResult> GetBusinessAnalysisReport(
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate,
        [FromQuery] string? branchSearch,
        CancellationToken cancellationToken = default)
    {
        var from = DateOnly.FromDateTime(fromDate ?? DateTime.UtcNow.AddDays(-30));
        var to = DateOnly.FromDateTime(toDate ?? DateTime.UtcNow);

        var invoices = _context.Invoices
            .AsNoTracking()
            .Include(invoice => invoice.Branch)
            .Where(invoice => invoice.InvoiceDate >= from && invoice.InvoiceDate <= to);

        if (!string.IsNullOrWhiteSpace(branchSearch))
        {
            invoices = invoices.Where(invoice => invoice.Branch.BranchName.Contains(branchSearch));
        }

        var invoiceList = await invoices.ToListAsync(cancellationToken);
        var totalRevenue = invoiceList.Sum(invoice => invoice.TotalAmount);
        var categoryDetails = _context.InvoiceDetails
            .AsNoTracking()
            .Include(detail => detail.Invoice)
            .ThenInclude(invoice => invoice.Branch)
            .Include(detail => detail.Medicine)
            .Where(detail => detail.Invoice.InvoiceDate >= from && detail.Invoice.InvoiceDate <= to);

        if (!string.IsNullOrWhiteSpace(branchSearch))
        {
            categoryDetails = categoryDetails.Where(detail =>
                detail.Invoice.Branch.BranchName.Contains(branchSearch));
        }

        var salesByCategory = await categoryDetails
            .GroupBy(detail => detail.Medicine.Category ?? "Uncategorized")
            .Select(group => new
            {
                category = group.Key,
                revenue = group.Sum(detail => detail.LineTotal)
            })
            .OrderByDescending(item => item.revenue)
            .ToListAsync(cancellationToken);

        var response = new
        {
            reportId = Guid.NewGuid(),
            generatedAt = DateTime.UtcNow,
            summary = new
            {
                totalRevenue,
                netProfitMargin = 0,
                customerGrowth = 0,
                averageBasketSize = invoiceList.Count == 0 ? 0 : totalRevenue / invoiceList.Count,
                completedTransactionCount = invoiceList.Count
            },
            revenueTrend = invoiceList
                .GroupBy(invoice => invoice.InvoiceDate.ToString("yyyy-MM"))
                .Select(group => new
                {
                    period = group.Key,
                    revenue = group.Sum(invoice => invoice.TotalAmount)
                })
                .OrderBy(item => item.period)
                .ToList(),
            salesByCategory,
            branchFinancialSummary = invoiceList
                .GroupBy(invoice => new { invoice.BranchId, invoice.Branch.BranchName, invoice.Branch.Status })
                .Select(group => new
                {
                    branchId = group.Key.BranchId,
                    branchName = group.Key.BranchName,
                    revenue = group.Sum(invoice => invoice.TotalAmount),
                    status = group.Key.Status
                })
                .OrderByDescending(item => item.revenue)
                .ToList()
        };

        return Ok(response);
    }

    private IActionResult? ValidateBranchRequest(BranchRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.BranchName))
        {
            return BadRequest(new { message = "Branch name is required." });
        }

        if (string.IsNullOrWhiteSpace(request.Address))
        {
            return BadRequest(new { message = "Address is required." });
        }

        return null;
    }

    private static object ToBranchResponse(Branch branch) => new
    {
        branchId = branch.BranchId,
        branchName = branch.BranchName,
        address = branch.Address,
        phone = branch.Phone,
        latitude = branch.Latitude,
        longitude = branch.Longitude,
        status = branch.Status,
        managerName = (string?)null,
        createdAt = branch.CreatedAt,
        updatedAt = branch.UpdatedAt
    };
}

public sealed record BranchRequest(
    string BranchName,
    string Address,
    string? Phone,
    double? Latitude,
    double? Longitude,
    string? Status);
