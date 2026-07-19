using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public sealed class StockReplenishmentService : IStockReplenishmentService
{
    private static readonly string[] OpenStatuses = ["PENDING", "PROCESSING", "SHIPPED"];
    private readonly PharmacyDbContext _dbContext;

    public StockReplenishmentService(PharmacyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<StockReplenishmentOptionDto>> GetOptionsAsync(
        Guid branchId,
        CancellationToken cancellationToken)
    {
        return await _dbContext.Medicines
            .AsNoTracking()
            .Where(medicine => medicine.Status.ToUpper() == "ACTIVE")
            .OrderBy(medicine => medicine.MedicineName)
            .Select(medicine => new StockReplenishmentOptionDto(
                medicine.MedicineId,
                medicine.MedicineName,
                medicine.Category ?? "Uncategorized",
                medicine.Unit,
                medicine.Inventories
                    .Where(inventory => inventory.BranchId == branchId)
                    .Sum(inventory => (int?)inventory.QuantityOnHand) ?? 0,
                medicine.Inventories
                    .Where(inventory => inventory.BranchId == branchId)
                    .Sum(inventory => (int?)inventory.SafetyStockLevel) ?? 0))
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<StockReplenishmentRequestDto>> GetBranchRequestsAsync(
        Guid branchId,
        CancellationToken cancellationToken)
    {
        var requests = await BuildRequestQuery()
            .Where(request => request.BranchId == branchId)
            .OrderByDescending(request => request.CreatedAt)
            .ToListAsync(cancellationToken);
        return requests.Select(Map).ToList();
    }

    public async Task<IReadOnlyList<StockReplenishmentRequestDto>> GetInventoryQueueAsync(
        string? status,
        CancellationToken cancellationToken)
    {
        var query = BuildRequestQuery();
        if (!string.IsNullOrWhiteSpace(status)
            && !status.Equals("ALL", StringComparison.OrdinalIgnoreCase))
        {
            var normalizedStatus = status.Trim().ToUpperInvariant();
            query = query.Where(request => request.Status == normalizedStatus);
        }

        var requests = await query
            .OrderBy(request => request.Status == "PENDING" ? 0 : 1)
            .ThenByDescending(request => request.Priority == "URGENT")
            .ThenBy(request => request.CreatedAt)
            .ToListAsync(cancellationToken);
        return requests.Select(Map).ToList();
    }

    public async Task<Result<StockReplenishmentRequestDto>> CreateAsync(
        Guid managerId,
        Guid branchId,
        CreateStockReplenishmentRequestDto request,
        CancellationToken cancellationToken)
    {
        var medicineIds = request.Items.Select(item => item.MedicineId).ToList();
        if (medicineIds.Count != medicineIds.Distinct().Count())
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                "StockReplenishment.DuplicateMedicine",
                "Each medicine can appear only once in a replenishment request."));
        }

        var validMedicineIds = await _dbContext.Medicines
            .AsNoTracking()
            .Where(medicine => medicineIds.Contains(medicine.MedicineId)
                && medicine.Status.ToUpper() == "ACTIVE")
            .Select(medicine => medicine.MedicineId)
            .ToListAsync(cancellationToken);
        if (validMedicineIds.Count != medicineIds.Count)
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                "StockReplenishment.InvalidMedicine",
                "One or more selected medicines do not exist or are inactive."));
        }

        var alreadyRequested = await _dbContext.StockReplenishmentRequestDetails
            .AsNoTracking()
            .Where(detail => medicineIds.Contains(detail.MedicineId)
                && detail.Request.BranchId == branchId
                && OpenStatuses.Contains(detail.Request.Status))
            .Select(detail => detail.Medicine.MedicineName)
            .Distinct()
            .ToListAsync(cancellationToken);
        if (alreadyRequested.Count > 0)
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.Conflict(
                "StockReplenishment.AlreadyOpen",
                $"An open replenishment request already exists for: {string.Join(", ", alreadyRequested)}."));
        }

        var now = DateTime.UtcNow;
        var entity = new StockReplenishmentRequest
        {
            RequestId = Guid.NewGuid(),
            RequestNo = $"REQ-{BranchManagerDataService.GetVietnamToday():yyyyMMdd}-{Guid.NewGuid():N}"[..19].ToUpperInvariant(),
            BranchId = branchId,
            RequestedBy = managerId,
            Priority = request.Priority.Trim().ToUpperInvariant(),
            Status = "PENDING",
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            RequestDate = BranchManagerDataService.GetVietnamToday(),
            CreatedAt = now,
            UpdatedAt = now,
            Details = request.Items.Select(item => new StockReplenishmentRequestDetail
            {
                RequestDetailId = Guid.NewGuid(),
                MedicineId = item.MedicineId,
                RequestedQuantity = item.Quantity
            }).ToList()
        };

        _dbContext.StockReplenishmentRequests.Add(entity);
        await _dbContext.SaveChangesAsync(cancellationToken);
        var saved = await BuildRequestQuery()
            .SingleAsync(item => item.RequestId == entity.RequestId, cancellationToken);
        return Result.Success(Map(saved));
    }

    public async Task<Result<StockReplenishmentRequestDto>> UpdateStatusAsync(
        Guid requestId,
        Guid inventoryManagerId,
        UpdateStockReplenishmentStatusDto request,
        CancellationToken cancellationToken)
    {
        var entity = await BuildRequestQuery(tracking: true)
            .SingleOrDefaultAsync(item => item.RequestId == requestId, cancellationToken);
        if (entity is null)
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.NotFound(
                "StockReplenishment.NotFound",
                "The replenishment request was not found."));
        }

        var nextStatus = request.Status.Trim().ToUpperInvariant();
        if (!IsValidTransition(entity.Status, nextStatus))
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.Conflict(
                "StockReplenishment.InvalidTransition",
                $"The request cannot move from {entity.Status} to {nextStatus}."));
        }
        if (nextStatus == "REJECTED" && string.IsNullOrWhiteSpace(request.InventoryNote))
        {
            return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                "StockReplenishment.RejectionReasonRequired",
                "A reason is required when rejecting a replenishment request."));
        }

        var now = DateTime.UtcNow;
        entity.Status = nextStatus;
        entity.InventoryNote = string.IsNullOrWhiteSpace(request.InventoryNote)
            ? null
            : request.InventoryNote.Trim();
        entity.ProcessedBy = inventoryManagerId;
        entity.ProcessedAt = now;
        entity.UpdatedAt = now;
        await _dbContext.SaveChangesAsync(cancellationToken);
        return Result.Success(Map(entity));
    }

    public async Task<Result<IReadOnlyList<StockReplenishmentSourceDto>>> GetDispatchSourcesAsync(
        Guid requestId,
        CancellationToken cancellationToken)
    {
        var request = await _dbContext.StockReplenishmentRequests
            .AsNoTracking()
            .Include(item => item.Details)
            .SingleOrDefaultAsync(item => item.RequestId == requestId, cancellationToken);
        if (request is null)
        {
            return Result.Failure<IReadOnlyList<StockReplenishmentSourceDto>>(Error.NotFound(
                "StockReplenishment.NotFound",
                "The replenishment request was not found."));
        }
        if (request.Status != "PROCESSING")
        {
            return Result.Failure<IReadOnlyList<StockReplenishmentSourceDto>>(Error.Conflict(
                "StockReplenishment.NotProcessing",
                "Only a request being processed can be dispatched."));
        }

        var medicineIds = request.Details.Select(detail => detail.MedicineId).ToList();
        var today = BranchManagerDataService.GetVietnamToday();
        var stockRows = await _dbContext.Inventories
            .AsNoTracking()
            .Where(inventory => inventory.BranchId != request.BranchId
                && inventory.Branch.Status.ToUpper() == "ACTIVE"
                && medicineIds.Contains(inventory.MedicineId)
                && inventory.QuantityOnHand > 0
                && (inventory.Status.ToUpper() == "ACTIVE"
                    || inventory.Status.ToUpper() == "INSTOCK")
                && (inventory.Batch.Status.ToUpper() == "SELLABLE"
                    || (inventory.Batch.Status.ToUpper() == "ACTIVE"
                        && (inventory.Batch.QcStatus.ToUpper() == "PASS"
                            || inventory.Batch.QcStatus.ToUpper() == "PASSED")))
                && inventory.Batch.ExpiryDate >= today)
            .Select(inventory => new
            {
                inventory.BranchId,
                inventory.Branch.BranchName,
                inventory.MedicineId,
                inventory.QuantityOnHand
            })
            .ToListAsync(cancellationToken);

        var required = request.Details.ToDictionary(
            detail => detail.MedicineId,
            detail => detail.RequestedQuantity);
        var sources = stockRows
            .GroupBy(row => new { row.BranchId, row.BranchName })
            .Where(group => required.All(requirement =>
                group.Where(row => row.MedicineId == requirement.Key)
                    .Sum(row => row.QuantityOnHand) >= requirement.Value))
            .OrderBy(group => group.Key.BranchName)
            .Select(group => new StockReplenishmentSourceDto(
                group.Key.BranchId,
                group.Key.BranchName))
            .ToList();
        return Result.Success<IReadOnlyList<StockReplenishmentSourceDto>>(sources);
    }

    public async Task<Result<StockReplenishmentRequestDto>> DispatchAsync(
        Guid requestId,
        Guid inventoryManagerId,
        DispatchStockReplenishmentDto request,
        CancellationToken cancellationToken)
    {
        await using var transaction = await _dbContext.Database.BeginTransactionAsync(
            System.Data.IsolationLevel.Serializable,
            cancellationToken);
        try
        {
            var entity = await BuildRequestQuery(tracking: true)
                .SingleOrDefaultAsync(item => item.RequestId == requestId, cancellationToken);
            if (entity is null)
            {
                return Result.Failure<StockReplenishmentRequestDto>(Error.NotFound(
                    "StockReplenishment.NotFound",
                    "The replenishment request was not found."));
            }
            if (entity.Status != "PROCESSING")
            {
                return Result.Failure<StockReplenishmentRequestDto>(Error.Conflict(
                    "StockReplenishment.NotProcessing",
                    "Only a request being processed can be dispatched."));
            }
            if (request.SourceBranchId == entity.BranchId)
            {
                return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                    "StockReplenishment.InvalidSource",
                    "The source and destination branches must be different."));
            }

            var sourceBranch = await _dbContext.Branches
                .AsNoTracking()
                .SingleOrDefaultAsync(branch => branch.BranchId == request.SourceBranchId
                    && branch.Status.ToUpper() == "ACTIVE", cancellationToken);
            if (sourceBranch is null)
            {
                return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                    "StockReplenishment.InvalidSource",
                    "The selected source branch is unavailable."));
            }

            var today = BranchManagerDataService.GetVietnamToday();
            var medicineIds = entity.Details.Select(detail => detail.MedicineId).ToList();
            var sourceInventories = await _dbContext.Inventories
                .Include(inventory => inventory.Batch)
                .Where(inventory => inventory.BranchId == request.SourceBranchId
                    && medicineIds.Contains(inventory.MedicineId)
                    && inventory.QuantityOnHand > 0
                    && (inventory.Status.ToUpper() == "ACTIVE"
                        || inventory.Status.ToUpper() == "INSTOCK")
                    && (inventory.Batch.Status.ToUpper() == "SELLABLE"
                        || (inventory.Batch.Status.ToUpper() == "ACTIVE"
                            && (inventory.Batch.QcStatus.ToUpper() == "PASS"
                                || inventory.Batch.QcStatus.ToUpper() == "PASSED")))
                    && inventory.Batch.ExpiryDate >= today)
                .OrderBy(inventory => inventory.Batch.ExpiryDate)
                .ThenBy(inventory => inventory.Batch.BatchNumber)
                .ToListAsync(cancellationToken);

            foreach (var detail in entity.Details)
            {
                var available = sourceInventories
                    .Where(inventory => inventory.MedicineId == detail.MedicineId)
                    .Sum(inventory => inventory.QuantityOnHand);
                if (available < detail.RequestedQuantity)
                {
                    return Result.Failure<StockReplenishmentRequestDto>(Error.Validation(
                        "StockReplenishment.InsufficientSourceStock",
                        $"The selected source does not have enough {detail.Medicine.MedicineName}. "
                        + $"Required: {detail.RequestedQuantity}, available: {available}."));
                }
            }

            var now = DateTime.UtcNow;
            var sourceBatchIds = sourceInventories
                .Select(inventory => inventory.BatchId)
                .Distinct()
                .ToList();
            var destinationInventories = await _dbContext.Inventories
                .Where(inventory => inventory.BranchId == entity.BranchId
                    && sourceBatchIds.Contains(inventory.BatchId))
                .ToDictionaryAsync(inventory => inventory.BatchId, cancellationToken);
            var transfer = new StockTransfer
            {
                TransferId = Guid.NewGuid(),
                FromBranchId = request.SourceBranchId,
                ToBranchId = entity.BranchId,
                RequestedBy = entity.RequestedBy,
                ApprovedBy = inventoryManagerId,
                TransferStatus = "RECEIVED",
                RequestDate = entity.RequestDate,
                ApprovedDate = today,
                Notes = $"Replenishment request {entity.RequestNo}",
                CreatedAt = now,
                UpdatedAt = now
            };

            foreach (var requestedItem in entity.Details)
            {
                var remaining = requestedItem.RequestedQuantity;
                foreach (var inventory in sourceInventories.Where(item =>
                    item.MedicineId == requestedItem.MedicineId))
                {
                    if (remaining == 0)
                    {
                        break;
                    }

                    var dispatchedQuantity = Math.Min(remaining, inventory.QuantityOnHand);
                    inventory.QuantityOnHand -= dispatchedQuantity;
                    inventory.UpdatedAt = now;
                    if (destinationInventories.TryGetValue(
                        inventory.BatchId,
                        out var destinationInventory))
                    {
                        destinationInventory.QuantityOnHand += dispatchedQuantity;
                        destinationInventory.Status = "ACTIVE";
                        destinationInventory.UpdatedAt = now;
                    }
                    else
                    {
                        destinationInventory = new Inventory
                        {
                            InventoryId = Guid.NewGuid(),
                            BranchId = entity.BranchId,
                            MedicineId = requestedItem.MedicineId,
                            BatchId = inventory.BatchId,
                            QuantityOnHand = dispatchedQuantity,
                            SafetyStockLevel = 0,
                            Status = "ACTIVE",
                            CreatedAt = now,
                            UpdatedAt = now
                        };
                        destinationInventories.Add(
                            inventory.BatchId,
                            destinationInventory);
                        _dbContext.Inventories.Add(destinationInventory);
                    }
                    transfer.StockTransferDetails.Add(new StockTransferDetail
                    {
                        TransferDetailId = Guid.NewGuid(),
                        MedicineId = requestedItem.MedicineId,
                        BatchId = inventory.BatchId,
                        Quantity = dispatchedQuantity
                    });
                    remaining -= dispatchedQuantity;
                }
            }

            entity.Transfer = transfer;
            entity.TransferId = transfer.TransferId;
            entity.Status = "FULFILLED";
            entity.InventoryNote = string.IsNullOrWhiteSpace(request.InventoryNote)
                ? entity.InventoryNote
                : request.InventoryNote.Trim();
            entity.ProcessedBy = inventoryManagerId;
            entity.ProcessedAt = now;
            entity.DispatchedAt = now;
            entity.ReceivedAt = now;
            entity.UpdatedAt = now;

            _dbContext.StockTransfers.Add(transfer);
            await _dbContext.SaveChangesAsync(cancellationToken);
            var saved = await BuildRequestQuery()
                .SingleAsync(item => item.RequestId == entity.RequestId, cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return Result.Success(Map(saved));
        }
        catch (DbUpdateConcurrencyException)
        {
            await transaction.RollbackAsync(cancellationToken);
            return Result.Failure<StockReplenishmentRequestDto>(Error.Conflict(
                "StockReplenishment.ConcurrentDispatch",
                "Stock changed while dispatching. Please refresh and try again."));
        }
        catch (Exception)
        {
            await transaction.RollbackAsync(cancellationToken);
            return Result.Failure<StockReplenishmentRequestDto>(Error.Failure(
                "StockReplenishment.DispatchFailed",
                "The medicines could not be dispatched."));
        }
    }

    private IQueryable<StockReplenishmentRequest> BuildRequestQuery(bool tracking = false)
    {
        var query = _dbContext.StockReplenishmentRequests
            .Include(request => request.Branch)
            .Include(request => request.RequestedByNavigation)
            .Include(request => request.Transfer)
                .ThenInclude(transfer => transfer!.FromBranch)
            .Include(request => request.Transfer)
                .ThenInclude(transfer => transfer!.StockTransferDetails)
            .Include(request => request.Details)
                .ThenInclude(detail => detail.Medicine)
            .AsSplitQuery();
        return tracking ? query : query.AsNoTracking();
    }

    private static bool IsValidTransition(string currentStatus, string nextStatus)
    {
        return currentStatus switch
        {
            "PENDING" => nextStatus is "PROCESSING" or "REJECTED",
            "PROCESSING" => nextStatus is "REJECTED",
            _ => false
        };
    }

    private static StockReplenishmentRequestDto Map(StockReplenishmentRequest request)
    {
        return new StockReplenishmentRequestDto(
            request.RequestId,
            request.RequestNo,
            request.BranchId,
            request.Branch.BranchName,
            request.RequestedBy,
            request.RequestedByNavigation.FullName,
            request.Priority,
            request.Status,
            request.Notes,
            request.InventoryNote,
            request.RequestDate,
            request.ProcessedAt,
            request.TransferId,
            request.Transfer?.FromBranch.BranchName,
            request.DispatchedAt,
            request.ReceivedAt,
            request.CreatedAt,
            request.Details
                .OrderBy(detail => detail.Medicine.MedicineName)
                .Select(detail => new StockReplenishmentItemDto(
                    detail.MedicineId,
                    detail.Medicine.MedicineName,
                    detail.Medicine.Unit,
                    detail.RequestedQuantity))
                .ToList());
    }
}
