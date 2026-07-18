using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;

namespace PharmacyChainsManagementBE.Services;

public interface IInventoryService
{
    Task<Result> ReceiveGoodsAsync(ReceiveGoodsRequest request, Guid createdBy, CancellationToken cancellationToken);
    Task<Result> QCInspectAsync(QCInspectionRequest request, Guid inspectedBy, CancellationToken cancellationToken);
    Task<Result> IssueStockAsync(IssueStockRequest request, Guid issuedBy, CancellationToken cancellationToken);
    Task<Result> ApproveTransferAsync(ApproveTransferRequest request, Guid approvedBy, CancellationToken cancellationToken);
    Task<Result> SubmitStocktakeAsync(StocktakeRequest request, Guid createdBy, CancellationToken cancellationToken);
    Task<Result> RecallBatchAsync(RecallBatchRequest request, Guid recalledBy, CancellationToken cancellationToken);
    Task<Result<BatchTraceabilityResponse>> GetBatchTraceabilityAsync(Guid batchId, CancellationToken cancellationToken);
    Task<Result<InventoryValuationResponse>> GetInventoryValuationAsync(Guid branchId, CancellationToken cancellationToken);
    Task CheckSafetyStockAndAlertAsync(Guid branchId, Guid medicineId, CancellationToken cancellationToken);
}
