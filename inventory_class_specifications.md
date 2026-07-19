# Inventory Module - UML Class Specifications & Coverage Report

**System:** Pharmacy Chains Management System (`PharmacyChainsManagement`)  
**Architectural Scope:** Inventory Module (`<<boundary>>`, `<<control>>`, `<<repository>>`, `<<DTO>>`, `<<entity>>`)  
**Methodology:** Reverse Engineered Strictly from Actual Source Code (`PharmacyChainsManagementBE` & `PharmacyChainsManagementFE`)  

---

## SECTION C: CLASS SPECIFICATIONS BY USE CASE

### UC01: View Inventory Dashboard & Valuation
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `InventoryDashboardScreen` | `<<boundary>>` | Primary dashboard UI showing stock value and low stock alerts | `build()`, `_onRefresh()`, `_onBranchChanged()` | `N/A` |
| `InventoryDashboardBloc` | `<<control>>` | Manage dashboard state transitions and valuation loading | `on<LoadInventoryDashboard>()`, `on<RefreshInventoryDashboard>()` | `InventoryValuationResponseDto` |
| `InventoryApiClient` | `<<boundary>>` | Call backend inventory valuation endpoint | `getInventoryValuation()`, `_shouldUseMock()` | `InventoryValuationResponseDto` |
| `InventoryController` | `<<control>>` | Handle valuation HTTP request | `GetInventoryValuation()` | `InventoryValuationResponse` |
| `InventoryService` | `<<control>>` | Execute valuation rules and aggregate costs | `GetInventoryValuationAsync()` | `Inventory`, `Medicine` |
| `PharmacyDbContext` | `<<repository>>` | Database access for inventories and medicines | `Inventories`, `Medicines` | `Inventory`, `Medicine` |
| `InventoryValuationResponseDto` | `<<DTO>>` | Transfer inventory valuation payload to frontend | `fromJson()` | `totalValue`, `items` |
| `Inventory` | `<<entity>>` | Store branch inventory quantity and cost | `N/A` | `InventoryId`, `Quantity`, `CostPrice` |
| `Medicine` | `<<entity>>` | Master medicine definition | `N/A` | `MedicineId`, `MedicineName`, `Sku` |

---

### UC02: Receive Goods
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `ReceiveGoodsScreen` | `<<boundary>>` | Inventory receiving form UI against PO or delivery note | `build()`, `_submitReceive()`, `_addItem()` | `ReceiveGoodsRequestDto` |
| `ReceiveGoodsBloc` | `<<control>>` | Manage receiving workflow and submit events | `on<SubmitReceiveGoods>()` | `ReceiveGoodsRequestDto` |
| `InventoryApiClient` | `<<boundary>>` | Call backend receive goods API | `receiveGoods()`, `_shouldUseMock()` | `ReceiveGoodsRequestDto` |
| `InventoryController` | `<<control>>` | Handle receive goods HTTP request | `ReceiveGoods()` | `ReceiveGoodsRequest` |
| `InventoryService` | `<<control>>` | Execute receiving rules, create pending QC batch | `ReceiveGoodsAsync()` | `InventoryReceipt`, `MedicineBatch`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database transaction management and table access | `BeginTransactionAsync()`, `InventoryReceipts`, `MedicineBatches`, `Inventories` | `InventoryReceipt`, `MedicineBatch`, `Inventory` |
| `ReceiveGoodsRequestDto` | `<<DTO>>` | Transfer receiving payload with items from FE | `toJson()` | `supplierId`, `poId`, `deliveryNoteNo`, `items` |
| `InventoryReceipt` | `<<entity>>` | Goods receipt header record | `N/A` | `ReceiptId`, `SupplierId`, `Status` |
| `MedicineBatch` | `<<entity>>` | Batch lot record awaiting inspection | `N/A` | `BatchId`, `BatchNumber`, `QcStatus` |

---

### UC03: Perform QC Inspection
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `QcInspectionScreen` | `<<boundary>>` | QC inspection UI for COA, temperature, and visual checks | `build()`, `_submitQcDecision()`, `_showInspectionModal()` | `N/A` |
| `InventoryApiClient` | `<<boundary>>` | Call backend QC inspection API | `qcInspect()`, `_shouldUseMock()` | `QCInspectionRequest` |
| `InventoryController` | `<<control>>` | Handle QC inspection HTTP request | `QCInspect()` | `QCInspectionRequest` |
| `InventoryService` | `<<control>>` | Execute QC rules, release or quarantine batch | `QCInspectAsync()` | `MedicineBatch`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database access for medicine batches and inventory | `MedicineBatches`, `Inventories`, `SaveChangesAsync()` | `MedicineBatch`, `Inventory` |
| `QCInspectionRequest` | `<<DTO>>` | Transfer pass/fail decision and notes | `N/A` | `BatchId`, `Passed`, `InspectorNotes` |
| `MedicineBatch` | `<<entity>>` | Batch lot under inspection | `N/A` | `BatchId`, `QcStatus`, `Status` |
| `Inventory` | `<<entity>>` | Branch inventory entry made active upon QC pass | `N/A` | `InventoryId`, `Quantity` |

---

### UC04: Issue Stock (FEFO Dispensing)
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `IssueStockScreen` | `<<boundary>>` | Stock dispensing UI enforcing FEFO batch selection | `build()`, `_submitIssue()`, `_addItem()` | `IssueStockRequestDto` |
| `IssueStockBloc` | `<<control>>` | Manage stock issuing workflow | `on<SubmitIssueStock>()` | `IssueStockRequestDto` |
| `InventoryApiClient` | `<<boundary>>` | Call backend issue stock API | `issueStock()`, `_shouldUseMock()` | `IssueStockRequestDto` |
| `InventoryController` | `<<control>>` | Handle issue stock HTTP request | `IssueStock()` | `IssueStockRequest` |
| `InventoryService` | `<<control>>` | Execute FEFO deduction algorithm (`OrderBy(ExpiryDate)`) | `IssueStockAsync()` | `StockIssue`, `StockIssueDetail`, `Inventory`, `MedicineBatch` |
| `PharmacyDbContext` | `<<repository>>` | Database transaction and stock tables access | `BeginTransactionAsync()`, `StockIssues`, `StockIssueDetails`, `Inventories` | `StockIssue`, `StockIssueDetail`, `Inventory` |
| `IssueStockRequestDto` | `<<DTO>>` | Transfer stock issue request payload | `toJson()` | `branchId`, `issueType`, `targetId`, `items` |
| `StockIssue` | `<<entity>>` | Header record of stock deduction | `N/A` | `IssueId`, `BranchId`, `IssueType` |
| `StockIssueDetail` | `<<entity>>` | Line item specifying deducted batch and quantity | `N/A` | `IssueDetailId`, `BatchId`, `Quantity` |
| `Inventory` | `<<entity>>` | Branch inventory stock level decremented by FEFO | `N/A` | `InventoryId`, `Quantity` |

---

### UC05: Approve Internal Transfer
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `InternalTransferApprovalScreen` | `<<boundary>>` | Inter-branch transfer approval UI | `build()`, `_processTransfer()`, `_showRejectTransferDialog()` | `N/A` |
| `InventoryApiClient` | `<<boundary>>` | Call backend transfer approval API | `approveTransfer()`, `_shouldUseMock()` | `ApproveTransferRequest` |
| `InventoryController` | `<<control>>` | Handle transfer approval HTTP request | `ApproveTransfer()` | `ApproveTransferRequest` |
| `InventoryService` | `<<control>>` | Execute inter-branch stock movement rules | `ApproveTransferAsync()` | `StockTransfer`, `StockTransferDetail`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database transaction and transfer tables access | `BeginTransactionAsync()`, `StockTransfers`, `StockTransferDetails`, `Inventories` | `StockTransfer`, `StockTransferDetail`, `Inventory` |
| `ApproveTransferRequest` | `<<DTO>>` | Transfer approval decision payload | `N/A` | `TransferId`, `ApprovalStatus`, `ApproverNotes` |
| `StockTransfer` | `<<entity>>` | Transfer header linking source and destination branches | `N/A` | `TransferId`, `FromBranchId`, `ToBranchId`, `Status` |
| `StockTransferDetail` | `<<entity>>` | Transfer line item specifying medicine and quantity | `N/A` | `TransferDetailId`, `MedicineId`, `Quantity` |

---

### UC06: Submit Stocktake & Blind Count
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `StocktakeScreen` | `<<boundary>>` | Physical blind count audit UI | `build()`, `_submit()`, `_buildTableHeader()` | `StocktakeRequestDto` |
| `StocktakeBloc` | `<<control>>` | Manage stocktake audit state and submission | `on<SubmitStocktake>()` | `StocktakeRequestDto` |
| `InventoryApiClient` | `<<boundary>>` | Call backend stocktake API | `submitStocktake()`, `_shouldUseMock()` | `StocktakeRequestDto` |
| `InventoryController` | `<<control>>` | Handle stocktake HTTP request | `SubmitStocktake()` | `StocktakeRequest` |
| `InventoryService` | `<<control>>` | Calculate variance (`Actual - Book`) and apply adjustment | `SubmitStocktakeAsync()` | `Stocktake`, `StocktakeDetail`, `InventoryAdjustment`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database access for stocktakes and adjustments | `BeginTransactionAsync()`, `Stocktakes`, `StocktakeDetails`, `InventoryAdjustments` | `Stocktake`, `InventoryAdjustment`, `Inventory` |
| `StocktakeRequestDto` | `<<DTO>>` | Transfer physical counts payload | `toJson()` | `branchId`, `scope`, `notes`, `items` |
| `Stocktake` | `<<entity>>` | Stocktake audit session header | `N/A` | `StocktakeId`, `BranchId`, `Scope` |
| `StocktakeDetail` | `<<entity>>` | Line item comparing book quantity with actual count | `N/A` | `StocktakeDetailId`, `BookQuantity`, `ActualQuantity` |
| `InventoryAdjustment` | `<<entity>>` | Financial adjustment created for non-zero variance | `N/A` | `AdjustmentId`, `VarianceQuantity`, `Reason` |

---

### UC07: Safety Stock & Background Alerts
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `ExpiredStockManagementScreen` | `<<boundary>>` | Quarantine and low stock threshold monitoring UI | `build()`, `_processAction()`, `_showDisposalReportDialog()` | `N/A` |
| `ExpiredStockBackgroundService` | `<<control>>` | Periodic background worker scanning expiring and low stock | `ExecuteAsync()` | `MedicineBatch`, `Inventory` |
| `InventoryService` | `<<control>>` | Check safety stock levels and alert when below minimum threshold (`< MinStockLevel`) | `CheckSafetyStockAndAlertAsync()` | `MedicineBatch`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database access for medicine batches and inventory levels | `MedicineBatches`, `Inventories`, `SaveChangesAsync()` | `MedicineBatch`, `Inventory` |
| `IAuditLogService` | `<<control>>` | Log safety stock alerts and quarantine actions for GSP audit | `LogAsync()` | `AuditLog` |
| `MedicineBatch` | `<<entity>>` | Batch lot checked for expiry date | `N/A` | `BatchId`, `ExpiryDate`, `Status` |
| `Inventory` | `<<entity>>` | Branch stock checked against minimum threshold | `N/A` | `InventoryId`, `Quantity`, `MinStockLevel` |

---

### UC08: Expired / Damaged Stock Management
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `ExpiredDamagedStockScreen` | `<<boundary>>` | Disposal request form UI for expired or damaged items | `build()`, `_submitDisposal()`, `_showConfirmDisposalDialog()` | `CreateDisposalRequestDto` |
| `InventoryApiClient` | `<<control>>` | Call backend stock disposal API | `submitDisposal()`, `_shouldUseMock()` | `CreateDisposalRequestDto` |
| `InventoryController` | `<<control>>` | Handle stock disposal HTTP request | `SubmitDisposal()` | `CreateDisposalRequest` |
| `InventoryService` | `<<service>>` | Execute stock deduction and record disposal log | `CreateDisposalRecordAsync()` | `StockDisposal`, `Inventory` |
| `PharmacyDbContext` | `<<repository>>` | Database transaction management for stock deductions | `BeginTransactionAsync()`, `StockDisposals`, `Inventories` | `StockDisposal`, `Inventory` |
| `CreateDisposalRequestDto` | `<<DTO>>` | Transfer disposal request payload | `toJson()` | `inventoryId`, `disposedQuantity`, `reason`, `disposalType` |
| `StockDisposal` | `<<entity>>` | Disposal log record capturing quantity and reason | `N/A` | `DisposalId`, `InventoryId`, `DisposedQuantity`, `Reason` |
| `Inventory` | `<<entity>>` | Branch stock decremented upon disposal approval | `N/A` | `InventoryId`, `QuantityOnHand` |

---

### UC09: Batch Tracking & Traceability
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `BatchTrackingScreen` | `<<boundary>>` | Batch tracking UI and traceability modal | `build()`, `_onRefresh()`, `showBatchDetailsModal()` | `N/A` |
| `BatchTrackingBloc` | `<<control>>` | Manage batch tracking list state transitions | `add()`, `on<LoadBatchTrackingList>()` | `BatchItem` |
| `InventoryApiClient` | `<<control>>` | Call backend medicine batch query and traceability APIs | `getMedicineBatches()`, `getBatchTraceability()` | `BatchTraceabilityResponseDto` |
| `InventoryController` | `<<control>>` | Handle batch tracking and traceability HTTP requests | `GetMedicineBatches()`, `GetBatchTraceability()` | `BatchTraceabilityResponse` |
| `InventoryService` | `<<service>>` | Execute batch filtering and supply chain history traversal | `GetMedicineBatchesAsync()`, `GetBatchTraceabilityAsync()` | `MedicineBatch`, `InventoryReceiptDetail`, `StockIssueDetail` |
| `PharmacyDbContext` | `<<repository>>` | Database access for batch lifecycle tables | `MedicineBatches`, `Inventories`, `InventoryReceiptDetails` | `MedicineBatch` |
| `BatchTraceabilityResponseDto` | `<<DTO>>` | Transfer supply chain history tree | `fromJson()` | `batchId`, `batchNumber`, `history` |
| `MedicineBatch` | `<<entity>>` | Master batch lot record | `N/A` | `BatchId`, `BatchNumber`, `ExpiryDate`, `Status` |

---

### UC10: Inventory Reports & Export
| Class | Type | Main Responsibility | Main Operations | Related Data |
| :--- | :--- | :--- | :--- | :--- |
| `InventoryReportScreen` | `<<boundary>>` | Analytical reporting UI displaying valuation, turnover rates, and export options | `build()`, `onSelectReportType()`, `onExportReport()` | `N/A` |
| `InventoryDashboardBloc` | `<<control>>` | Manage report state transitions and trigger export events | `add()`, `loadValuationReport()`, `exportReport()` | `InventoryValuationResponseDto` |
| `InventoryApiClient` | `<<control>>` | Call backend analytical reporting and export endpoints | `getInventoryValuation()`, `exportInventoryReport()` | `InventoryValuationResponseDto` |
| `InventoryController` | `<<control>>` | Handle report valuation query and CSV/Excel export HTTP requests | `GetInventoryValuation()`, `ExportReport()` | `InventoryValuationResponse` |
| `InventoryService` | `<<service>>` | Execute data aggregation, valuation calculations, and export file generation | `GetInventoryValuationAsync()`, `GenerateExportReportAsync()` | `Inventory`, `Medicine`, `MedicineBatch` |
| `PharmacyDbContext` | `<<repository>>` | Database access for inventory, medicine batches, and stock movements | `Inventories`, `MedicineBatches`, `SaveChangesAsync()` | `Inventory`, `MedicineBatch` |
| `InventoryValuationResponseDto` | `<<DTO>>` | Transfer aggregated inventory valuation and turnover breakdown to FE | `FromEntity()`, `fromJson()` | `TotalValuation`, `TurnoverRate`, `TotalSKUs` |
| `Inventory` | `<<entity>>` | Branch stock quantity and cost price records | `CalculateTotalValue()` | `InventoryId`, `QuantityOnHand`, `UnitCost` |

---

## FINAL REPORT

| UC | Class Diagram | Sequence Diagram | Class Specifications |
|----|----|----|----|
| **UC01 View Inventory Dashboard & Valuation** | `inventory_uml/UC01_ClassDiagram.drawio` | `inventory_uml/UC01_SequenceDiagram.drawio` | Section C (`UC01`) |
| **UC02 Receive Goods** | `inventory_uml/UC02_ClassDiagram.drawio` | `inventory_uml/UC02_SequenceDiagram.drawio` | Section C (`UC02`) |
| **UC03 Perform QC Inspection** | `inventory_uml/UC03_ClassDiagram.drawio` | `inventory_uml/UC03_SequenceDiagram.drawio` | Section C (`UC03`) |
| **UC04 Issue Stock (FEFO Dispensing)** | `inventory_uml/UC04_ClassDiagram.drawio` | `inventory_uml/UC04_SequenceDiagram.drawio` | Section C (`UC04`) |
| **UC05 Approve Internal Transfer** | `inventory_uml/UC05_ClassDiagram.drawio` | `inventory_uml/UC05_SequenceDiagram.drawio` | Section C (`UC05`) |
| **UC06 Submit Stocktake & Blind Count** | `inventory_uml/UC06_ClassDiagram.drawio` | `inventory_uml/UC06_SequenceDiagram.drawio` | Section C (`UC06`) |
| **UC07 Safety Stock & Background Alerts** | `inventory_uml/UC07_ClassDiagram.drawio` | `inventory_uml/UC07_SequenceDiagram.drawio` | Section C (`UC07`) |
| **UC08 Expired / Damaged Stock Management** | `inventory_uml/UC08_ClassDiagram.drawio` | `inventory_uml/UC08_SequenceDiagram.drawio` | Section C (`UC08`) |
| **UC09 Batch Tracking & Traceability** | `inventory_uml/UC09_ClassDiagram.drawio` | `inventory_uml/UC09_SequenceDiagram.drawio` | Section C (`UC09`) |
| **UC10 Inventory Reports & Export** | `inventory_uml/UC10_ClassDiagram.drawio` | `inventory_uml/UC10_SequenceDiagram.drawio` | Section C (`UC10`) |

**Coverage %: 100%**
