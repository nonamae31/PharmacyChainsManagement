using System;
using System.Collections.Generic;

namespace PharmacyChainsManagementBE.DTOs;

public record ReceiveGoodsRequest(
    Guid SupplierId,
    Guid? PoId,
    string? DeliveryNoteNo,
    DateTime ReceivedDate,
    List<ReceiveGoodsItem> Items
);

public record ReceiveGoodsItem(
    Guid MedicineId,
    string BatchNo,
    DateTime ExpiryDate,
    int Quantity
);

public record QCInspectionRequest(
    Guid ReceiptId,
    string InspectionResult, // PASS or FAIL
    string? DefectDescription,
    DateTime InspectionDate
);

public record IssueStockRequest(
    Guid StoreId, // BranchId for the store requesting stock
    string RequestNo,
    List<IssueStockItem> Items
);

public record IssueStockItem(
    Guid MedicineId,
    int Quantity
);

public record ApproveTransferRequest(
    Guid TransferId,
    string ApprovalStatus, // APPROVED or REJECTED
    string? RejectionReason
);

public record StocktakeRequest(
    Guid BranchId,
    DateTime StocktakeDate,
    string? Notes,
    List<StocktakeItem> Items
);

public record StocktakeItem(
    Guid MedicineId,
    Guid BatchId,
    int PhysicalQuantity
);

public record RecallBatchRequest(
    Guid BatchId,
    string Reason
);

public record BatchTraceabilityResponse(
    Guid BatchId,
    string BatchNumber,
    string CurrentStatus,
    List<BatchTraceHistoryItem> History
);

public record BatchTraceHistoryItem(
    DateTime Timestamp,
    string ActionType, // e.g., RECEIVED, QC_INSPECTED, ISSUED, TRANSFERRED, ADJUSTED, RECALLED
    string Description,
    Guid? LocationId,
    string? LocationName
);

public record InventoryValuationResponse(
    decimal TotalValue,
    List<InventoryValuationItem> Items
);

public record InventoryValuationItem(
    Guid MedicineId,
    string MedicineName,
    int TotalAvailableQuantity,
    decimal AverageCost,
    decimal TotalValue
);
