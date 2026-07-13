using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public class InventoryService : IInventoryService
{
    private readonly PharmacyDbContext _dbContext;
    private readonly ILogger<InventoryService> _logger;
    private readonly IAuditLogService _auditLogService;

    public InventoryService(
        PharmacyDbContext dbContext,
        ILogger<InventoryService> logger,
        IAuditLogService auditLogService)
    {
        _dbContext = dbContext;
        _logger = logger;
        _auditLogService = auditLogService;
    }

    public async Task<Result> ReceiveGoodsAsync(ReceiveGoodsRequest request, Guid createdBy, CancellationToken cancellationToken)
    {
        using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var receipt = new InventoryReceipt
            {
                ReceiptId = Guid.NewGuid(),
                SupplierId = request.SupplierId,
                PoId = request.PoId,
                DeliveryNoteNo = request.DeliveryNoteNo,
                ReceivedDate = request.ReceivedDate,
                Status = "PENDING_QC",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _dbContext.InventoryReceipts.AddAsync(receipt, cancellationToken);

            foreach (var item in request.Items)
            {
                // Create new batch for received goods
                var batch = new MedicineBatch
                {
                    BatchId = Guid.NewGuid(),
                    MedicineId = item.MedicineId,
                    SupplierId = request.SupplierId,
                    BatchNumber = item.BatchNo,
                    ExpiryDate = DateOnly.FromDateTime(item.ExpiryDate),
                    QcStatus = "PENDING",
                    Status = "PENDING_QC",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _dbContext.MedicineBatches.AddAsync(batch, cancellationToken);

                var detail = new InventoryReceiptDetail
                {
                    ReceiptDetailId = Guid.NewGuid(),
                    ReceiptId = receipt.ReceiptId,
                    MedicineId = item.MedicineId,
                    BatchId = batch.BatchId,
                    Quantity = item.Quantity
                };

                await _dbContext.InventoryReceiptDetails.AddAsync(detail, cancellationToken);

                // Add to Inventory, but since it's PENDING_QC, it won't affect Available Stock
                // Wait, ReceiveGoods doesn't specify which branch! Assuming Central Warehouse or it comes from PO branch
                var branchId = request.PoId.HasValue 
                    ? (await _dbContext.PurchaseOrders.FindAsync(new object[] { request.PoId.Value }, cancellationToken))?.BranchId 
                    : null;
                
                if (branchId == null)
                {
                    // Fallback to first warehouse
                    var warehouse = await _dbContext.Branches.FirstOrDefaultAsync(b => b.BranchType == "CENTRAL_WAREHOUSE", cancellationToken);
                    branchId = warehouse?.BranchId ?? Guid.Empty;
                }

                var inventory = await _dbContext.Inventories
                    .FirstOrDefaultAsync(i => i.BranchId == branchId && i.MedicineId == item.MedicineId && i.BatchId == batch.BatchId, cancellationToken);

                if (inventory == null)
                {
                    inventory = new Inventory
                    {
                        InventoryId = Guid.NewGuid(),
                        BranchId = branchId.Value,
                        MedicineId = item.MedicineId,
                        BatchId = batch.BatchId,
                        QuantityOnHand = item.Quantity,
                        SafetyStockLevel = 0,
                        Status = "ACTIVE",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    await _dbContext.Inventories.AddAsync(inventory, cancellationToken);
                }
                else
                {
                    inventory.QuantityOnHand += item.Quantity;
                    inventory.UpdatedAt = DateTime.UtcNow;
                }
            }

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            await _auditLogService.LogAsync("ReceiveGoods", $"Received PO {request.PoId}", createdBy.ToString(), null, cancellationToken);
            return Result.Success();
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(ex, "Error receiving goods");
            return Result.Failure(Error.Failure("Inventory.ReceiveFailed", "Failed to receive goods"));
        }
    }

    public async Task<Result> QCInspectAsync(QCInspectionRequest request, Guid inspectedBy, CancellationToken cancellationToken)
    {
        using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var receipt = await _dbContext.InventoryReceipts
                .Include(r => r.InventoryReceiptDetails)
                .FirstOrDefaultAsync(r => r.ReceiptId == request.ReceiptId, cancellationToken);

            if (receipt == null) return Result.Failure(Error.NotFound("QC.ReceiptNotFound", "Receipt not found"));

            bool isPass = request.InspectionResult.Equals("PASS", StringComparison.OrdinalIgnoreCase);
            receipt.Status = isPass ? "COMPLETED" : "REJECTED";
            receipt.UpdatedAt = DateTime.UtcNow;

            foreach (var detail in receipt.InventoryReceiptDetails)
            {
                var batch = await _dbContext.MedicineBatches.FindAsync(new object[] { detail.BatchId }, cancellationToken);
                if (batch != null)
                {
                    batch.QcStatus = isPass ? "PASS" : "FAIL";
                    batch.Status = isPass ? "SELLABLE" : "QUARANTINE";
                    batch.UpdatedAt = DateTime.UtcNow;
                }
            }

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            await _auditLogService.LogAsync("QCInspect", $"QC for Receipt {request.ReceiptId} resulted in {request.InspectionResult}", inspectedBy.ToString(), null, cancellationToken);
            return Result.Success();
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(ex, "Error in QC Inspection");
            return Result.Failure(Error.Failure("QC.Failed", "Failed to process QC"));
        }
    }

    public async Task<Result> IssueStockAsync(IssueStockRequest request, Guid issuedBy, CancellationToken cancellationToken)
    {
        using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var stockIssue = new StockIssue
            {
                IssueId = Guid.NewGuid(),
                RequestNo = request.RequestNo,
                BranchId = request.StoreId,
                IssueDate = DateTime.UtcNow,
                Status = "COMPLETED",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _dbContext.StockIssues.AddAsync(stockIssue, cancellationToken);

            foreach (var item in request.Items)
            {
                int remainingToIssue = item.Quantity;

                // FEFO: Find all sellable, non-expired batches for this medicine in this store
                var availableInventories = await _dbContext.Inventories
                    .Include(i => i.Batch)
                    .Where(i => i.BranchId == request.StoreId 
                                && i.MedicineId == item.MedicineId 
                                && i.QuantityOnHand > 0
                                && i.Batch.Status == "SELLABLE"
                                && i.Batch.ExpiryDate >= DateOnly.FromDateTime(DateTime.UtcNow))
                    .OrderBy(i => i.Batch.ExpiryDate) // FEFO
                    .ToListAsync(cancellationToken);

                int totalAvailable = availableInventories.Sum(i => i.QuantityOnHand);
                if (totalAvailable < item.Quantity)
                {
                    await transaction.RollbackAsync(cancellationToken);
                    return Result.Failure(Error.Validation("Inventory.InsufficientStock", $"Not enough available stock for medicine {item.MedicineId}. Required: {item.Quantity}, Available: {totalAvailable}"));
                }

                foreach (var inv in availableInventories)
                {
                    if (remainingToIssue <= 0) break;

                    int qtyToTake = Math.Min(remainingToIssue, inv.QuantityOnHand);
                    inv.QuantityOnHand -= qtyToTake;
                    inv.UpdatedAt = DateTime.UtcNow;

                    var issueDetail = new StockIssueDetail
                    {
                        IssueDetailId = Guid.NewGuid(),
                        IssueId = stockIssue.IssueId,
                        MedicineId = item.MedicineId,
                        BatchId = inv.BatchId,
                        Quantity = qtyToTake
                    };
                    await _dbContext.StockIssueDetails.AddAsync(issueDetail, cancellationToken);

                    remainingToIssue -= qtyToTake;
                }
            }

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            await _auditLogService.LogAsync("IssueStock", $"Issued stock {request.RequestNo} to Branch {request.StoreId}", issuedBy.ToString(), null, cancellationToken);
            
            // Fire and forget safety stock check
            foreach (var item in request.Items)
            {
                _ = CheckSafetyStockAndAlertAsync(request.StoreId, item.MedicineId, CancellationToken.None);
            }

            return Result.Success();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogWarning(ex, "Concurrency error during IssueStock");
            return Result.Failure(Error.Failure("Inventory.Concurrency", "Stock was modified by another process. Please try again."));
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(ex, "Error in IssueStock");
            return Result.Failure(Error.Failure("Inventory.IssueFailed", "Failed to issue stock"));
        }
    }

    public async Task<Result> ApproveTransferAsync(ApproveTransferRequest request, Guid approvedBy, CancellationToken cancellationToken)
    {
        using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var transfer = await _dbContext.StockTransfers
                .Include(t => t.StockTransferDetails)
                .FirstOrDefaultAsync(t => t.TransferId == request.TransferId, cancellationToken);

            if (transfer == null) return Result.Failure(Error.NotFound("Transfer.NotFound", "Transfer not found"));
            if (transfer.Status != "PENDING") return Result.Failure(Error.Validation("Transfer.NotPending", "Transfer is not in pending state"));

            bool isApproved = request.ApprovalStatus.Equals("APPROVED", StringComparison.OrdinalIgnoreCase);
            transfer.Status = request.ApprovalStatus;
            transfer.ApprovedBy = approvedBy;
            transfer.UpdatedAt = DateTime.UtcNow;

            if (isApproved)
            {
                foreach (var detail in transfer.StockTransferDetails)
                {
                    // Decrease from Source
                    var sourceInv = await _dbContext.Inventories
                        .FirstOrDefaultAsync(i => i.BranchId == transfer.FromBranchId && i.BatchId == detail.BatchId, cancellationToken);

                    if (sourceInv == null || sourceInv.QuantityOnHand < detail.Quantity)
                    {
                        await transaction.RollbackAsync(cancellationToken);
                        return Result.Failure(Error.Validation("Transfer.InsufficientStock", $"Not enough stock in source branch for batch {detail.BatchId}"));
                    }

                    sourceInv.QuantityOnHand -= detail.Quantity;
                    sourceInv.UpdatedAt = DateTime.UtcNow;

                    // Increase Destination
                    var destInv = await _dbContext.Inventories
                        .FirstOrDefaultAsync(i => i.BranchId == transfer.ToBranchId && i.BatchId == detail.BatchId, cancellationToken);

                    if (destInv == null)
                    {
                        destInv = new Inventory
                        {
                            InventoryId = Guid.NewGuid(),
                            BranchId = transfer.ToBranchId,
                            MedicineId = detail.MedicineId,
                            BatchId = detail.BatchId,
                            QuantityOnHand = detail.Quantity,
                            SafetyStockLevel = 0,
                            Status = "ACTIVE",
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        await _dbContext.Inventories.AddAsync(destInv, cancellationToken);
                    }
                    else
                    {
                        destInv.QuantityOnHand += detail.Quantity;
                        destInv.UpdatedAt = DateTime.UtcNow;
                    }
                }
            }

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            return Result.Success();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogWarning(ex, "Concurrency error during ApproveTransfer");
            return Result.Failure(Error.Failure("Inventory.Concurrency", "Stock was modified by another process. Please try again."));
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(ex, "Error in ApproveTransfer");
            return Result.Failure(Error.Failure("Transfer.ApproveFailed", "Failed to approve transfer"));
        }
    }

    public async Task<Result> SubmitStocktakeAsync(StocktakeRequest request, Guid createdBy, CancellationToken cancellationToken)
    {
        using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var stocktake = new Stocktake
            {
                StocktakeId = Guid.NewGuid(),
                BranchId = request.BranchId,
                CreatedBy = createdBy,
                StocktakeDate = request.StocktakeDate,
                Status = "COMPLETED",
                Notes = request.Notes,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            await _dbContext.Stocktakes.AddAsync(stocktake, cancellationToken);

            foreach (var item in request.Items)
            {
                var inv = await _dbContext.Inventories
                    .FirstOrDefaultAsync(i => i.BranchId == request.BranchId && i.BatchId == item.BatchId, cancellationToken);

                int systemQty = inv?.QuantityOnHand ?? 0;
                int diff = item.PhysicalQuantity - systemQty;

                var detail = new StocktakeDetail
                {
                    StocktakeDetailId = Guid.NewGuid(),
                    StocktakeId = stocktake.StocktakeId,
                    MedicineId = item.MedicineId,
                    BatchId = item.BatchId,
                    SystemQuantity = systemQty,
                    PhysicalQuantity = item.PhysicalQuantity
                };
                await _dbContext.StocktakeDetails.AddAsync(detail, cancellationToken);

                if (diff != 0)
                {
                    string adjType = diff < 0 ? "LOSS" : "GAIN";
                    var adj = new InventoryAdjustment
                    {
                        AdjustmentId = Guid.NewGuid(),
                        StocktakeDetailId = detail.StocktakeDetailId,
                        InventoryId = inv?.InventoryId ?? Guid.Empty, // If it's a completely new batch found, need to create inv first
                        AdjustmentType = adjType,
                        Quantity = Math.Abs(diff),
                        CreatedAt = DateTime.UtcNow
                    };

                    if (inv == null && diff > 0)
                    {
                        inv = new Inventory
                        {
                            InventoryId = Guid.NewGuid(),
                            BranchId = request.BranchId,
                            MedicineId = item.MedicineId,
                            BatchId = item.BatchId,
                            QuantityOnHand = diff,
                            Status = "ACTIVE",
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        await _dbContext.Inventories.AddAsync(inv, cancellationToken);
                        await _dbContext.SaveChangesAsync(cancellationToken); // Need ID for adjustment
                        adj.InventoryId = inv.InventoryId;
                    }
                    else if (inv != null)
                    {
                        inv.QuantityOnHand = item.PhysicalQuantity;
                        inv.UpdatedAt = DateTime.UtcNow;
                    }

                    await _dbContext.InventoryAdjustments.AddAsync(adj, cancellationToken);
                }
            }

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return Result.Success();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogWarning(ex, "Concurrency error during Stocktake");
            return Result.Failure(Error.Failure("Inventory.Concurrency", "Stock was modified by another process. Please try again."));
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(ex, "Error in SubmitStocktake");
            return Result.Failure(Error.Failure("Stocktake.Failed", "Failed to submit stocktake"));
        }
    }

    public async Task<Result> RecallBatchAsync(RecallBatchRequest request, Guid recalledBy, CancellationToken cancellationToken)
    {
        var batch = await _dbContext.MedicineBatches.FindAsync(new object[] { request.BatchId }, cancellationToken);
        if (batch == null) return Result.Failure(Error.NotFound("Batch.NotFound", "Batch not found"));

        batch.Status = "RECALLED";
        batch.UpdatedAt = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);
        await _auditLogService.LogAsync("BatchRecall", $"Batch {request.BatchId} recalled: {request.Reason}", recalledBy.ToString(), null, cancellationToken);

        return Result.Success();
    }

    public async Task<Result<BatchTraceabilityResponse>> GetBatchTraceabilityAsync(Guid batchId, CancellationToken cancellationToken)
    {
        var batch = await _dbContext.MedicineBatches
            .Include(b => b.Supplier)
            .FirstOrDefaultAsync(b => b.BatchId == batchId, cancellationToken);

        if (batch == null) return Result.Failure<BatchTraceabilityResponse>(Error.NotFound("Batch.NotFound", "Batch not found"));

        var history = new List<BatchTraceHistoryItem>();

        // 1. Receive
        var receipts = await _dbContext.InventoryReceiptDetails
            .Include(d => d.Receipt)
            .Where(d => d.BatchId == batchId)
            .ToListAsync(cancellationToken);
        foreach (var r in receipts)
        {
            history.Add(new BatchTraceHistoryItem(r.Receipt.ReceivedDate, "RECEIVED", $"Received from Supplier {batch.Supplier.SupplierName}", null, null));
            history.Add(new BatchTraceHistoryItem(r.Receipt.UpdatedAt, "QC_INSPECTED", $"QC Status: {batch.QcStatus}", null, null));
        }

        // 2. Transfers
        var transfers = await _dbContext.StockTransferDetails
            .Include(d => d.Transfer).ThenInclude(t => t.FromBranch)
            .Include(d => d.Transfer).ThenInclude(t => t.ToBranch)
            .Where(d => d.BatchId == batchId && d.Transfer.Status == "APPROVED")
            .ToListAsync(cancellationToken);
        foreach (var t in transfers)
        {
            history.Add(new BatchTraceHistoryItem(t.Transfer.UpdatedAt, "TRANSFERRED", $"Transferred {t.Quantity} from {t.Transfer.FromBranch.BranchName} to {t.Transfer.ToBranch.BranchName}", t.Transfer.ToBranchId, t.Transfer.ToBranch.BranchName));
        }

        // 3. Issues
        var issues = await _dbContext.StockIssueDetails
            .Include(d => d.Issue).ThenInclude(i => i.Branch)
            .Where(d => d.BatchId == batchId)
            .ToListAsync(cancellationToken);
        foreach (var i in issues)
        {
            history.Add(new BatchTraceHistoryItem(i.Issue.IssueDate, "ISSUED", $"Issued {i.Quantity} at {i.Issue.Branch.BranchName}", i.Issue.BranchId, i.Issue.Branch.BranchName));
        }

        // Sort timeline
        history = history.OrderBy(h => h.Timestamp).ToList();

        return Result.Success(new BatchTraceabilityResponse(batch.BatchId, batch.BatchNumber, batch.Status, history));
    }

    public async Task<Result<InventoryValuationResponse>> GetInventoryValuationAsync(Guid branchId, CancellationToken cancellationToken)
    {
        // Simple Average Cost using standard price
        var inventories = await _dbContext.Inventories
            .Include(i => i.Medicine)
            .Include(i => i.Batch)
            .Where(i => i.BranchId == branchId && i.QuantityOnHand > 0 && i.Batch.Status == "SELLABLE")
            .ToListAsync(cancellationToken);

        var grouped = inventories.GroupBy(i => i.Medicine).Select(g => new InventoryValuationItem(
            g.Key.MedicineId,
            g.Key.MedicineName,
            g.Sum(x => x.QuantityOnHand),
            g.Key.StandardPrice, // Assuming StandardPrice is our cost for now
            g.Sum(x => x.QuantityOnHand) * g.Key.StandardPrice
        )).ToList();

        var totalValue = grouped.Sum(x => x.TotalValue);

        return Result.Success(new InventoryValuationResponse(totalValue, grouped));
    }

    public async Task CheckSafetyStockAndAlertAsync(Guid branchId, Guid medicineId, CancellationToken cancellationToken)
    {
        var inventories = await _dbContext.Inventories
            .Include(i => i.Batch)
            .Where(i => i.BranchId == branchId && i.MedicineId == medicineId)
            .ToListAsync(cancellationToken);

        int totalAvailable = inventories
            .Where(i => i.Batch.Status == "SELLABLE" && i.Batch.ExpiryDate >= DateOnly.FromDateTime(DateTime.UtcNow))
            .Sum(i => i.QuantityOnHand);

        // Assume safety stock is the max safety stock defined across batches or a constant
        int safetyStock = inventories.FirstOrDefault()?.SafetyStockLevel ?? 0;

        if (totalAvailable < safetyStock)
        {
            _logger.LogWarning($"Low Stock Alert! Branch {branchId}, Medicine {medicineId}. Available: {totalAvailable}, Safety: {safetyStock}");
            // Integration with Email/Notification system
        }
    }
}
