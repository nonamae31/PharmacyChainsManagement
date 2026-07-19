import 'package:equatable/equatable.dart';

class StockReplenishmentOptionDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final String category;
  final String unit;
  final int currentStock;
  final int reorderPoint;

  const StockReplenishmentOptionDto({
    required this.medicineId,
    required this.medicineName,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.reorderPoint,
  });

  factory StockReplenishmentOptionDto.fromJson(Map<String, dynamic> json) =>
      StockReplenishmentOptionDto(
        medicineId: json['medicineId'].toString(),
        medicineName: json['medicineName']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        unit: json['unit']?.toString() ?? '',
        currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
        reorderPoint: (json['reorderPoint'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    category,
    unit,
    currentStock,
    reorderPoint,
  ];
}

class CreateStockReplenishmentItemDto extends Equatable {
  final String medicineId;
  final int quantity;

  const CreateStockReplenishmentItemDto({
    required this.medicineId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'medicineId': medicineId,
    'quantity': quantity,
  };

  @override
  List<Object?> get props => [medicineId, quantity];
}

class CreateStockReplenishmentRequestDto extends Equatable {
  final String priority;
  final String? notes;
  final List<CreateStockReplenishmentItemDto> items;

  const CreateStockReplenishmentRequestDto({
    required this.priority,
    required this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'priority': priority,
    'notes': notes,
    'items': items.map((item) => item.toJson()).toList(growable: false),
  };

  @override
  List<Object?> get props => [priority, notes, items];
}

class StockReplenishmentItemDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final String unit;
  final int requestedQuantity;

  const StockReplenishmentItemDto({
    required this.medicineId,
    required this.medicineName,
    required this.unit,
    required this.requestedQuantity,
  });

  factory StockReplenishmentItemDto.fromJson(Map<String, dynamic> json) =>
      StockReplenishmentItemDto(
        medicineId: json['medicineId'].toString(),
        medicineName: json['medicineName']?.toString() ?? '',
        unit: json['unit']?.toString() ?? '',
        requestedQuantity: (json['requestedQuantity'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    unit,
    requestedQuantity,
  ];
}

class StockReplenishmentSourceDto extends Equatable {
  final String branchId;
  final String branchName;

  const StockReplenishmentSourceDto({
    required this.branchId,
    required this.branchName,
  });

  factory StockReplenishmentSourceDto.fromJson(Map<String, dynamic> json) =>
      StockReplenishmentSourceDto(
        branchId: json['branchId'].toString(),
        branchName: json['branchName']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [branchId, branchName];
}

class DispatchStockReplenishmentDto extends Equatable {
  final String sourceBranchId;
  final String? inventoryNote;

  const DispatchStockReplenishmentDto({
    required this.sourceBranchId,
    required this.inventoryNote,
  });

  Map<String, dynamic> toJson() => {
    'sourceBranchId': sourceBranchId,
    'inventoryNote': inventoryNote,
  };

  @override
  List<Object?> get props => [sourceBranchId, inventoryNote];
}

class StockReplenishmentRequestDto extends Equatable {
  final String requestId;
  final String requestNo;
  final String branchId;
  final String branchName;
  final String requestedBy;
  final String requestedByName;
  final String priority;
  final String status;
  final String? notes;
  final String? inventoryNote;
  final DateTime requestDate;
  final DateTime? processedAt;
  final String? transferId;
  final String? sourceBranchName;
  final DateTime? dispatchedAt;
  final DateTime? receivedAt;
  final DateTime createdAt;
  final List<StockReplenishmentItemDto> items;

  const StockReplenishmentRequestDto({
    required this.requestId,
    required this.requestNo,
    required this.branchId,
    required this.branchName,
    required this.requestedBy,
    required this.requestedByName,
    required this.priority,
    required this.status,
    required this.notes,
    required this.inventoryNote,
    required this.requestDate,
    required this.processedAt,
    this.transferId,
    this.sourceBranchName,
    this.dispatchedAt,
    this.receivedAt,
    required this.createdAt,
    required this.items,
  });

  factory StockReplenishmentRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => StockReplenishmentRequestDto(
    requestId: json['requestId'].toString(),
    requestNo: json['requestNo']?.toString() ?? '',
    branchId: json['branchId'].toString(),
    branchName: json['branchName']?.toString() ?? '',
    requestedBy: json['requestedBy'].toString(),
    requestedByName: json['requestedByName']?.toString() ?? '',
    priority: json['priority']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    notes: json['notes']?.toString(),
    inventoryNote: json['inventoryNote']?.toString(),
    requestDate: DateTime.parse(json['requestDate'].toString()),
    processedAt: json['processedAt'] == null
        ? null
        : DateTime.parse(json['processedAt'].toString()),
    transferId: json['transferId']?.toString(),
    sourceBranchName: json['sourceBranchName']?.toString(),
    dispatchedAt: json['dispatchedAt'] == null
        ? null
        : DateTime.parse(json['dispatchedAt'].toString()),
    receivedAt: json['receivedAt'] == null
        ? null
        : DateTime.parse(json['receivedAt'].toString()),
    createdAt: DateTime.parse(json['createdAt'].toString()),
    items: (json['items'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              StockReplenishmentItemDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
  );

  @override
  List<Object?> get props => [
    requestId,
    requestNo,
    branchId,
    branchName,
    requestedBy,
    requestedByName,
    priority,
    status,
    notes,
    inventoryNote,
    requestDate,
    processedAt,
    transferId,
    sourceBranchName,
    dispatchedAt,
    receivedAt,
    createdAt,
    items,
  ];
}

class UpdateStockReplenishmentStatusDto extends Equatable {
  final String status;
  final String? inventoryNote;

  const UpdateStockReplenishmentStatusDto({
    required this.status,
    required this.inventoryNote,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'inventoryNote': inventoryNote,
  };

  @override
  List<Object?> get props => [status, inventoryNote];
}
