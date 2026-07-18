import 'package:equatable/equatable.dart';

class BranchInventoryRowDto extends Equatable {
  final String medicineId;
  final String sku;
  final String medicineName;
  final String category;
  final int currentStock;
  final int reorderPoint;
  final String status;
  final String supplier;
  final DateTime lastSync;
  final double inventoryValue;

  const BranchInventoryRowDto({
    required this.medicineId,
    required this.sku,
    required this.medicineName,
    required this.category,
    required this.currentStock,
    required this.reorderPoint,
    required this.status,
    required this.supplier,
    required this.lastSync,
    required this.inventoryValue,
  });

  factory BranchInventoryRowDto.fromJson(Map<String, dynamic> json) => BranchInventoryRowDto(
        medicineId: json['medicineId'].toString(),
        sku: json['sku']?.toString() ?? '',
        medicineName: json['medicineName']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
        reorderPoint: (json['reorderPoint'] as num?)?.toInt() ?? 0,
        status: json['status']?.toString() ?? '',
        supplier: json['supplier']?.toString() ?? '',
        lastSync: DateTime.parse(json['lastSync'].toString()),
        inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'sku': sku,
        'medicineName': medicineName,
        'category': category,
        'currentStock': currentStock,
        'reorderPoint': reorderPoint,
        'status': status,
        'supplier': supplier,
        'lastSync': lastSync.toIso8601String(),
        'inventoryValue': inventoryValue,
      };

  @override
  List<Object?> get props => [medicineId, sku, medicineName, category, currentStock, reorderPoint, status, supplier, lastSync, inventoryValue];
}

class BranchInventoryDto extends Equatable {
  final String branchId;
  final int totalItems;
  final int criticalStock;
  final int inTransit;
  final double inventoryValue;
  final int page;
  final int pageSize;
  final int totalRecords;
  final List<String> categories;
  final List<BranchInventoryRowDto> items;

  const BranchInventoryDto({
    required this.branchId,
    required this.totalItems,
    required this.criticalStock,
    required this.inTransit,
    required this.inventoryValue,
    required this.page,
    required this.pageSize,
    required this.totalRecords,
    required this.categories,
    required this.items,
  });

  factory BranchInventoryDto.fromJson(Map<String, dynamic> json) => BranchInventoryDto(
        branchId: json['branchId'].toString(),
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        criticalStock: (json['criticalStock'] as num?)?.toInt() ?? 0,
        inTransit: (json['inTransit'] as num?)?.toInt() ?? 0,
        inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
        totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
        categories: (json['categories'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(growable: false),
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((item) => BranchInventoryRowDto.fromJson(item as Map<String, dynamic>)).toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'totalItems': totalItems,
        'criticalStock': criticalStock,
        'inTransit': inTransit,
        'inventoryValue': inventoryValue,
        'page': page,
        'pageSize': pageSize,
        'totalRecords': totalRecords,
        'categories': categories,
        'items': items.map((item) => item.toJson()).toList(),
      };

  @override
  List<Object?> get props => [branchId, totalItems, criticalStock, inTransit, inventoryValue, page, pageSize, totalRecords, categories, items];
}
