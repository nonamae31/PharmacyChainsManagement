using System;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.DTOs.Responses;
using PharmacyChainsManagementBE.Filters;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[Route("api/v1/business-admin")]
[ApiController]
public class BusinessAdminController : ControllerBase
{
    private const string BusinessAdminDashboardRoles = "BusinessAdmin,BUSINESS_ADMIN,Founder,SuperAdmin";

    private readonly IBusinessAdminService _businessAdminService;
    private readonly MediatR.IMediator _mediator;
    private readonly PharmacyDbContext _context;
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;
    private readonly IEmailAlertQueue _emailAlertQueue;

    public BusinessAdminController(
        IBusinessAdminService businessAdminService,
        MediatR.IMediator mediator,
        PharmacyDbContext context,
        IPasswordHashingStrategy passwordHashingStrategy,
        IEmailAlertQueue emailAlertQueue)
    {
        _businessAdminService = businessAdminService;
        _mediator = mediator;
        _context = context;
        _passwordHashingStrategy = passwordHashingStrategy;
        _emailAlertQueue = emailAlertQueue;
    }

    [HttpGet("branches")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> GetDashboardBranches(
        [FromQuery] string? search,
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Branches.AsNoTracking().AsQueryable();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var keyword = search.Trim().ToLower();
            query = query.Where(branch =>
                branch.BranchName.ToLower().Contains(keyword) ||
                branch.Address.ToLower().Contains(keyword) ||
                (branch.Phone != null && branch.Phone.Contains(keyword)));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(branch => branch.Status == status);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var items = await query
            .OrderBy(branch => branch.BranchName)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(branch => new
            {
                branch.BranchId,
                branch.BranchName,
                branch.Address,
                branch.Phone,
                branch.Latitude,
                branch.Longitude,
                branch.Status,
                ManagerName = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.FullName)
                    .FirstOrDefault(),
                ManagerId = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => (Guid?)user.UserId)
                    .FirstOrDefault(),
                ManagerEmail = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.Email)
                    .FirstOrDefault(),
                ManagerPhone = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.Phone)
                    .FirstOrDefault(),
                ManagerStatus = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => user.Status)
                    .FirstOrDefault(),
                ManagerJoinedDate = branch.Users
                    .Where(user => !user.IsDeleted && user.Role.RoleCode == "BRANCH_MANAGER")
                    .Select(user => (DateTime?)user.CreatedAt)
                    .FirstOrDefault(),
                DailyRevenue = branch.Invoices
                    .Where(invoice => invoice.InvoiceDate == today && invoice.PaymentStatus == "Paid")
                    .Sum(invoice => (decimal?)invoice.TotalAmount) ?? 0m,
                StaffCount = branch.Users.Count(user => !user.IsDeleted),
                branch.CreatedAt,
                branch.UpdatedAt
            })
            .ToListAsync(cancellationToken);

        return Ok(new { data = new { items, totalCount, page, pageSize } });
    }

    [HttpPost("branches")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> CreateDashboardBranch([FromBody] BranchUpsertRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.BranchName) || string.IsNullOrWhiteSpace(request.Address))
        {
            return BadRequest(new { message = "Branch name and address are required." });
        }

        var now = DateTime.UtcNow;
        var branch = new Branch
        {
            BranchId = Guid.NewGuid(),
            BranchName = request.BranchName.Trim(),
            Address = request.Address.Trim(),
            Phone = request.Phone?.Trim(),
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim(),
            CreatedAt = now,
            UpdatedAt = now
        };

        _context.Branches.Add(branch);
        await _context.SaveChangesAsync(cancellationToken);

        return Ok(new { data = ToBranchResponse(branch) });
    }

    [HttpPost("branches/{branchId:guid}/manager-account")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> CreateBranchManagerAccount(
        Guid branchId,
        [FromBody] BranchManagerAccountUpsertRequest request,
        CancellationToken cancellationToken)
    {
        var branch = await _context.Branches.FirstOrDefaultAsync(item => item.BranchId == branchId, cancellationToken);
        if (branch == null)
        {
            return NotFound(new { message = "Branch not found." });
        }

        var validationMessage = ValidateBranchManagerAccount(request);
        if (validationMessage != null)
        {
            return BadRequest(new { message = validationMessage });
        }

        var existingManager = await _context.Users
            .Include(user => user.Role)
            .FirstOrDefaultAsync(user => !user.IsDeleted
                && user.BranchId == branchId
                && user.Role.RoleCode == "BRANCH_MANAGER", cancellationToken);
        if (existingManager != null)
        {
            return Conflict(new { message = "This branch already has a manager account." });
        }

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var duplicateEmail = await _context.Users
            .AnyAsync(user => !user.IsDeleted && user.Email == normalizedEmail, cancellationToken);
        if (duplicateEmail)
        {
            return Conflict(new { message = "Email already exists in the system." });
        }

        var managerRole = await _context.Roles
            .FirstOrDefaultAsync(role => role.RoleCode == "BRANCH_MANAGER" && role.IsActive, cancellationToken);
        if (managerRole == null)
        {
            return BadRequest(new { message = "BRANCH_MANAGER role not found." });
        }

        var rawPassword = GenerateSecurePassword();
        var now = DateTime.UtcNow;
        var manager = new User
        {
            UserId = Guid.NewGuid(),
            BranchId = branchId,
            RoleId = managerRole.RoleId,
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            Phone = request.Phone?.Trim(),
            PasswordHash = _passwordHashingStrategy.HashPassword(rawPassword),
            Status = "ACTIVE",
            CreatedAt = now,
            UpdatedAt = now,
            MustChangePassword = true
        };

        _context.Users.Add(manager);
        await _context.SaveChangesAsync(cancellationToken);
        await SendBranchManagerCredentialsAsync(manager, branch, rawPassword, cancellationToken);

        return Ok(new { data = ToBranchResponse(branch, manager) });
    }

    [HttpPut("branches/{branchId:guid}/manager-account/{managerId:guid}")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> UpdateBranchManagerAccount(
        Guid branchId,
        Guid managerId,
        [FromBody] BranchManagerAccountUpsertRequest request,
        CancellationToken cancellationToken)
    {
        var manager = await _context.Users
            .Include(user => user.Branch)
            .Include(user => user.Role)
            .FirstOrDefaultAsync(user => user.UserId == managerId
                && user.BranchId == branchId
                && !user.IsDeleted
                && user.Role.RoleCode == "BRANCH_MANAGER", cancellationToken);
        if (manager == null)
        {
            return NotFound(new { message = "Branch manager account not found." });
        }

        var validationMessage = ValidateBranchManagerAccount(request);
        if (validationMessage != null)
        {
            return BadRequest(new { message = validationMessage });
        }

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var duplicateEmail = await _context.Users
            .AnyAsync(user => !user.IsDeleted
                && user.UserId != managerId
                && user.Email == normalizedEmail, cancellationToken);
        if (duplicateEmail)
        {
            return Conflict(new { message = "Email already exists in the system." });
        }

        manager.FullName = request.FullName.Trim();
        manager.Email = normalizedEmail;
        manager.Phone = request.Phone?.Trim();
        manager.Status = string.IsNullOrWhiteSpace(request.Status)
            ? manager.Status
            : request.Status.Trim().ToUpperInvariant();
        manager.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return Ok(new { data = ToBranchResponse(manager.Branch!, manager) });
    }

    [HttpPost("branches/{branchId:guid}/manager-account/{managerId:guid}/reset-password")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> ResetBranchManagerPassword(
        Guid branchId,
        Guid managerId,
        CancellationToken cancellationToken)
    {
        var manager = await _context.Users
            .Include(user => user.Branch)
            .Include(user => user.Role)
            .FirstOrDefaultAsync(user => user.UserId == managerId
                && user.BranchId == branchId
                && !user.IsDeleted
                && user.Role.RoleCode == "BRANCH_MANAGER", cancellationToken);
        if (manager == null)
        {
            return NotFound(new { message = "Branch manager account not found." });
        }

        var rawPassword = GenerateSecurePassword();
        manager.PasswordHash = _passwordHashingStrategy.HashPassword(rawPassword);
        manager.MustChangePassword = true;
        manager.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);
        await SendBranchManagerCredentialsAsync(manager, manager.Branch!, rawPassword, cancellationToken);

        return Ok(new { data = ToBranchResponse(manager.Branch!, manager) });
    }

    [HttpDelete("branches/{branchId:guid}/manager-account/{managerId:guid}")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> DeleteBranchManagerAccount(
        Guid branchId,
        Guid managerId,
        CancellationToken cancellationToken)
    {
        var manager = await _context.Users
            .Include(user => user.Branch)
            .Include(user => user.Role)
            .FirstOrDefaultAsync(user => user.UserId == managerId
                && user.BranchId == branchId
                && !user.IsDeleted
                && user.Role.RoleCode == "BRANCH_MANAGER", cancellationToken);
        if (manager == null)
        {
            return NotFound(new { message = "Branch manager account not found." });
        }

        var branch = manager.Branch!;
        manager.IsDeleted = true;
        manager.Status = "DEACTIVATED";
        manager.BranchId = null;
        manager.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);

        return Ok(new { data = ToBranchResponse(branch) });
    }

    [HttpPut("branches/{branchId:guid}")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> UpdateDashboardBranch(
        Guid branchId,
        [FromBody] BranchUpsertRequest request,
        CancellationToken cancellationToken)
    {
        var branch = await _context.Branches.FirstOrDefaultAsync(item => item.BranchId == branchId, cancellationToken);
        if (branch == null)
        {
            return NotFound(new { message = "Branch not found." });
        }

        if (string.IsNullOrWhiteSpace(request.BranchName) || string.IsNullOrWhiteSpace(request.Address))
        {
            return BadRequest(new { message = "Branch name and address are required." });
        }

        branch.BranchName = request.BranchName.Trim();
        branch.Address = request.Address.Trim();
        branch.Phone = request.Phone?.Trim();
        branch.Latitude = request.Latitude;
        branch.Longitude = request.Longitude;
        branch.Status = string.IsNullOrWhiteSpace(request.Status) ? branch.Status : request.Status.Trim();
        branch.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return Ok(new { data = ToBranchResponse(branch) });
    }

    [HttpGet("medicine-statistics")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> GetMedicineStatistics(
        [FromQuery] Guid? branchId,
        [FromQuery] string? category,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(page, 1);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Inventories
            .AsNoTracking()
            .Include(item => item.Branch)
            .Include(item => item.Medicine)
            .Include(item => item.Batch)
            .AsQueryable();

        if (branchId.HasValue)
        {
            query = query.Where(item => item.BranchId == branchId.Value);
        }

        if (!string.IsNullOrWhiteSpace(category))
        {
            query = query.Where(item => item.Medicine.Category == category);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var keyword = search.Trim().ToLower();
            query = query.Where(item =>
                item.Medicine.MedicineName.ToLower().Contains(keyword) ||
                item.Batch.BatchNumber.ToLower().Contains(keyword));
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var nearExpiryLimit = today.AddDays(30);

        var allItems = await query
            .OrderBy(item => item.Medicine.MedicineName)
            .Select(item => new MedicineInventoryResponse(
                item.MedicineId,
                item.Medicine.MedicineName,
                item.Medicine.Category,
                item.Branch.BranchName,
                item.Batch.BatchNumber,
                item.QuantityOnHand,
                item.SafetyStockLevel,
                item.Batch.ExpiryDate,
                item.Status))
            .ToListAsync(cancellationToken);

        var inventoryItems = allItems
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        var lowStockList = allItems
            .Where(item => item.QuantityOnHand > 0 && item.QuantityOnHand <= item.SafetyStockLevel)
            .Take(10)
            .ToList();

        var nearExpiryList = allItems
            .Where(item => item.ExpiryDate <= nearExpiryLimit)
            .Take(10)
            .ToList();

        var totalLines = allItems.Count;
        var healthyLines = allItems.Count(item => item.QuantityOnHand > item.SafetyStockLevel);
        var fulfillmentRate = totalLines == 0 ? 0 : Math.Round(healthyLines * 100d / totalLines, 2);

        var bestSellingList = await _context.InvoiceDetails
            .AsNoTracking()
            .Include(detail => detail.Medicine)
            .GroupBy(detail => new { detail.MedicineId, detail.Medicine.MedicineName })
            .Select(group => new
            {
                group.Key.MedicineId,
                group.Key.MedicineName,
                QuantitySold = group.Sum(detail => detail.Quantity),
                Revenue = group.Sum(detail => detail.LineTotal)
            })
            .OrderByDescending(item => item.QuantitySold)
            .Take(5)
            .ToListAsync(cancellationToken);

        return Ok(new
        {
            data = new
            {
                generatedAt = DateTime.UtcNow,
                summary = new
                {
                    totalMedicines = await _context.Medicines.AsNoTracking().CountAsync(cancellationToken),
                    outOfStockCount = allItems.Count(item => item.QuantityOnHand <= 0),
                    lowStockCount = lowStockList.Count,
                    nearExpiryCount = nearExpiryList.Count,
                    fulfillmentRate
                },
                inventoryItems,
                bestSellingList,
                lowStockList,
                nearExpiryList
            }
        });
    }

    [HttpGet("reports/business-analysis")]
    [Authorize(Roles = BusinessAdminDashboardRoles)]
    public async Task<IActionResult> GetBusinessAnalysisReport(
        [FromQuery] string? fromDate,
        [FromQuery] string? toDate,
        [FromQuery] string? branchSearch,
        CancellationToken cancellationToken = default)
    {
        var from = ParseDateOnly(fromDate) ?? DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-30));
        var to = ParseDateOnly(toDate) ?? DateOnly.FromDateTime(DateTime.UtcNow);

        var invoices = _context.Invoices
            .AsNoTracking()
            .Where(invoice => invoice.InvoiceDate >= from && invoice.InvoiceDate <= to);

        if (!string.IsNullOrWhiteSpace(branchSearch))
        {
            var keyword = branchSearch.Trim().ToLower();
            invoices = invoices.Where(invoice => invoice.Branch.BranchName.ToLower().Contains(keyword));
        }

        var totalRevenue = await invoices.SumAsync(invoice => (decimal?)invoice.TotalAmount, cancellationToken) ?? 0m;
        var completedTransactionCount = await invoices.CountAsync(cancellationToken);
        var averageBasketSize = completedTransactionCount == 0 ? 0m : totalRevenue / completedTransactionCount;

        var revenueTrend = await invoices
            .GroupBy(invoice => new { invoice.InvoiceDate.Year, invoice.InvoiceDate.Month })
            .Select(group => new
            {
                Period = group.Key.Year + "-" + group.Key.Month.ToString().PadLeft(2, '0'),
                Revenue = group.Sum(invoice => invoice.TotalAmount)
            })
            .OrderBy(item => item.Period)
            .ToListAsync(cancellationToken);

        var salesByCategory = await _context.InvoiceDetails
            .AsNoTracking()
            .Where(detail => detail.Invoice.InvoiceDate >= from && detail.Invoice.InvoiceDate <= to)
            .GroupBy(detail => detail.Medicine.Category ?? "Uncategorized")
            .Select(group => new
            {
                Category = group.Key,
                Revenue = group.Sum(detail => detail.LineTotal)
            })
            .OrderByDescending(item => item.Revenue)
            .ToListAsync(cancellationToken);

        var branchFinancialSummary = await _context.Branches
            .AsNoTracking()
            .Where(branch => string.IsNullOrWhiteSpace(branchSearch) || branch.BranchName.ToLower().Contains(branchSearch.Trim().ToLower()))
            .Select(branch => new
            {
                branch.BranchId,
                branch.BranchName,
                Revenue = branch.Invoices
                    .Where(invoice => invoice.InvoiceDate >= from && invoice.InvoiceDate <= to)
                    .Sum(invoice => (decimal?)invoice.TotalAmount) ?? 0m,
                branch.Status
            })
            .OrderByDescending(item => item.Revenue)
            .ToListAsync(cancellationToken);

        return Ok(new
        {
            data = new
            {
                reportId = Guid.NewGuid().ToString(),
                generatedAt = DateTime.UtcNow,
                summary = new
                {
                    totalRevenue,
                    netProfitMargin = totalRevenue == 0 ? 0 : 24.8,
                    customerGrowth = 5.1,
                    averageBasketSize,
                    completedTransactionCount
                },
                revenueTrend,
                salesByCategory,
                branchFinancialSummary
            }
        });
    }

    /// <summary>
    /// Gets business admin details by ID.
    /// </summary>
    /// <param name="accountId">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin details.</returns>
    [HttpGet("{accountId}")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("GetAdminPolicy")]
    [ResponseCache(Duration = 60, Location = ResponseCacheLocation.Client)]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBusinessAdmin(Guid accountId, CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminAsync(accountId, cancellationToken);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Gets a list of all business admins.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of business admins.</returns>
    [HttpGet]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("GetAdminPolicy")]
    [ProducesResponseType(typeof(ApiResponse<System.Collections.Generic.List<BusinessAdminDetailResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetBusinessAdmins(CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminsAsync(cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Creates a new business admin account.
    /// </summary>
    /// <param name="request">The create request data.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin details.</returns>
    [HttpPost]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("CreateAdminPolicy")]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status409Conflict)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateBusinessAdmin([FromBody] DTOs.CreateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.CreateBusinessAdminAsync(request, ipAddress, cancellationToken);
        if (!result.Success && result.Message == "Email đã tồn tại trong hệ thống.")
        {
            return Conflict(result);
        }
        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Gets business admin status by ID.
    /// </summary>
    /// <param name="adminId">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Business admin status.</returns>
    [HttpGet("{adminId}/status")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBusinessAdminStatus(Guid adminId, CancellationToken cancellationToken)
    {
        var result = await _businessAdminService.GetBusinessAdminStatusAsync(adminId, cancellationToken);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Deactivates a business admin account.
    /// </summary>
    /// <param name="adminId">The account ID.</param>
    /// <param name="request">The deactivate request data containing reason.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpPost("{adminId}/deactivate")]
    [Authorize(Roles = "Founder")]
    [IdempotencyKey]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> DeactivateBusinessAdmin(Guid adminId, [FromBody] DeactivateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.VerifyAndDeactivateAsync(adminId, request.Reason, ipAddress, cancellationToken);
        if (!result.Success)
        {
            if (result.Message == "Business Admin không tồn tại.")
                return NotFound(result);
            return BadRequest(result);
        }

        return Ok(result);
    }
    /// <summary>
    /// Updates business admin profile.
    /// </summary>
    /// <param name="accountId">The account ID.</param>
    /// <param name="request">The update request data.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpPut("{accountId}")]
    [Authorize(Policy = "RequireSuperAdminOrOwner")]
    [EnableRateLimiting("ProfileUpdatePolicy")]
    [ProducesResponseType(typeof(ApiResponse<BusinessAdminDetailResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> UpdateBusinessAdmin(Guid accountId, [FromBody] UpdateBusinessAdminRequest request, CancellationToken cancellationToken)
    {
        var currentUserIdClaim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var currentUserRoleClaim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Role)?.Value;

        Guid currentUserId = Guid.Empty;
        if (currentUserIdClaim != null) Guid.TryParse(currentUserIdClaim, out currentUserId);

        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _businessAdminService.UpdateBusinessAdminAsync(accountId, request, currentUserId, currentUserRoleClaim, ipAddress, cancellationToken);

        if (!result.Success)
        {
            if (result.Message.Contains("không tồn tại"))
                return NotFound(result);
            if (result.Message.Contains("tồn tại trong hệ thống"))
                return Conflict(result);
            if (result.Message.Contains("quyền") || result.Message.Contains("truy cập"))
                return StatusCode(403, result);
            return BadRequest(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Soft deletes a business admin account.
    /// </summary>
    /// <param name="id">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Founder")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SoftDeleteBusinessAdmin(Guid id, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var command = new PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.SoftDeleteBusinessAdmin.SoftDeleteBusinessAdminCommand(id, ipAddress);
        var result = await _mediator.Send(command, cancellationToken);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Reactivates a soft-deleted business admin account.
    /// </summary>
    /// <param name="id">The account ID.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Result message.</returns>
    [HttpPatch("{id}/reactivate")]
    [Authorize(Roles = "Founder")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ReactivateBusinessAdmin(Guid id, CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var command = new PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.ReactivateBusinessAdmin.ReactivateBusinessAdminCommand(id, ipAddress);
        var result = await _mediator.Send(command, cancellationToken);
        if (!result.Success)
        {
            if (result.Message == "Business Admin không tồn tại.")
                return NotFound(result);
            return BadRequest(result);
        }

        return Ok(result);
    }

    private static object ToBranchResponse(Branch branch)
    {
        return new
        {
            branch.BranchId,
            branch.BranchName,
            branch.Address,
            branch.Phone,
            branch.Latitude,
            branch.Longitude,
            branch.Status,
            ManagerId = (Guid?)null,
            ManagerName = (string?)null,
            ManagerEmail = (string?)null,
            ManagerPhone = (string?)null,
            ManagerStatus = (string?)null,
            ManagerJoinedDate = (DateTime?)null,
            DailyRevenue = 0m,
            StaffCount = 0,
            branch.CreatedAt,
            branch.UpdatedAt
        };
    }

    private static object ToBranchResponse(Branch branch, User manager)
    {
        return new
        {
            branch.BranchId,
            branch.BranchName,
            branch.Address,
            branch.Phone,
            branch.Latitude,
            branch.Longitude,
            branch.Status,
            ManagerId = manager.UserId,
            ManagerName = manager.FullName,
            ManagerEmail = manager.Email,
            ManagerPhone = manager.Phone,
            ManagerStatus = manager.Status,
            ManagerJoinedDate = (DateTime?)manager.CreatedAt,
            DailyRevenue = 0m,
            StaffCount = branch.Users.Count(user => !user.IsDeleted),
            branch.CreatedAt,
            branch.UpdatedAt
        };
    }

    private static DateOnly? ParseDateOnly(string? value)
    {
        return DateOnly.TryParseExact(value, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date)
            ? date
            : null;
    }

    public sealed record BranchUpsertRequest(
        string BranchName,
        string Address,
        string? Phone,
        decimal? Latitude,
        decimal? Longitude,
        string? Status);

    public sealed record BranchManagerAccountUpsertRequest(
        string FullName,
        string Email,
        string? Phone,
        string? Status);

    private static string? ValidateBranchManagerAccount(BranchManagerAccountUpsertRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return "Manager name is required.";
        }

        if (string.IsNullOrWhiteSpace(request.Email) || !request.Email.Contains('@'))
        {
            return "Valid manager email is required.";
        }

        return null;
    }

    private static string GenerateSecurePassword(int length = 12)
    {
        const string validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*";
        var result = new char[length];
        using var rng = RandomNumberGenerator.Create();
        var buffer = new byte[length];
        rng.GetBytes(buffer);
        for (var index = 0; index < length; index++)
        {
            result[index] = validChars[buffer[index] % validChars.Length];
        }

        return new string(result);
    }

    private async Task SendBranchManagerCredentialsAsync(
        User manager,
        Branch branch,
        string rawPassword,
        CancellationToken cancellationToken)
    {
        await _emailAlertQueue.EnqueueEmailAsync(new EmailMessage(
            manager.Email,
            "Branch Manager Account Created",
            $"""
            Hello {manager.FullName},

            Your Branch Manager account for {branch.BranchName} has been created.

            Login email: {manager.Email}
            Temporary password: {rawPassword}

            Please sign in and change your password after the first login.
            """
        ), cancellationToken);
    }

    private sealed record MedicineInventoryResponse(
        Guid MedicineId,
        string MedicineName,
        string? Category,
        string BranchName,
        string? BatchNumber,
        int QuantityOnHand,
        int SafetyStockLevel,
        DateOnly ExpiryDate,
        string Status);
}
