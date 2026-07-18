import 'package:equatable/equatable.dart';

class MedicineStatisticsFilterDto extends Equatable {
  final String? branchId;
  final String? category;
  final String? search;
  final int page;
  final int pageSize;

  const MedicineStatisticsFilterDto({
    this.branchId,
    this.category,
    this.search,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParameters() => {
    'branchId': branchId,
    'category': category,
    'search': search,
    'page': page,
    'pageSize': pageSize,
  }..removeWhere((_, value) => value == null || value == '');

  @override
  List<Object?> get props => [branchId, category, search, page, pageSize];
}

class MedicineStatisticsDto extends Equatable {
  final DateTime generatedAt;
  final int totalMedicines;
  final int outOfStockCount;
  final int lowStockCount;
  final int nearExpiryCount;
  final double? fulfillmentRate;
  final List<MedicineInventoryItemDto> inventoryItems;
  final List<MedicineRankingItemDto> bestSellingList;
  final List<MedicineInventoryItemDto> lowStockList;
  final List<MedicineInventoryItemDto> nearExpiryList;

  const MedicineStatisticsDto({
    required this.generatedAt,
    required this.totalMedicines,
    required this.outOfStockCount,
    required this.lowStockCount,
    required this.nearExpiryCount,
    required this.inventoryItems,
    required this.bestSellingList,
    required this.lowStockList,
    required this.nearExpiryList,
    this.fulfillmentRate,
  });

  factory MedicineStatisticsDto.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return MedicineStatisticsDto(
      generatedAt:
          DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalMedicines: summary['totalMedicines'] as int? ?? 0,
      outOfStockCount: summary['outOfStockCount'] as int? ?? 0,
      lowStockCount: summary['lowStockCount'] as int? ?? 0,
      nearExpiryCount: summary['nearExpiryCount'] as int? ?? 0,
      fulfillmentRate: (summary['fulfillmentRate'] as num?)?.toDouble(),
      inventoryItems: _items(json['inventoryItems']),
      bestSellingList: _rankingItems(json['bestSellingList']),
      lowStockList: _items(json['lowStockList']),
      nearExpiryList: _items(json['nearExpiryList']),
    );
  }

  static List<MedicineInventoryItemDto> _items(Object? value) {
    return (value as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicineInventoryItemDto.fromJson)
        .toList();
  }

  static List<MedicineRankingItemDto> _rankingItems(Object? value) {
    return (value as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicineRankingItemDto.fromJson)
        .toList();
  }

  @override
  List<Object?> get props => [
    generatedAt,
    totalMedicines,
    outOfStockCount,
    lowStockCount,
    nearExpiryCount,
    fulfillmentRate,
    inventoryItems,
    bestSellingList,
    lowStockList,
    nearExpiryList,
  ];
}

class MedicineInventoryItemDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final String? category;
  final String branchName;
  final String? batchNumber;
  final int quantityOnHand;
  final int safetyStockLevel;
  final DateTime? expiryDate;
  final String status;

  const MedicineInventoryItemDto({
    required this.medicineId,
    required this.medicineName,
    required this.branchName,
    required this.quantityOnHand,
    required this.safetyStockLevel,
    required this.status,
    this.category,
    this.batchNumber,
    this.expiryDate,
  });

  factory MedicineInventoryItemDto.fromJson(Map<String, dynamic> json) =>
      MedicineInventoryItemDto(
        medicineId: json['medicineId'].toString(),
        medicineName: json['medicineName']?.toString() ?? '',
        category: json['category']?.toString(),
        branchName: json['branchName']?.toString() ?? '',
        batchNumber: json['batchNumber']?.toString(),
        quantityOnHand: json['quantityOnHand'] as int? ?? 0,
        safetyStockLevel: json['safetyStockLevel'] as int? ?? 0,
        expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? ''),
        status: json['status']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    category,
    branchName,
    batchNumber,
    quantityOnHand,
    safetyStockLevel,
    expiryDate,
    status,
  ];
}

class MedicineRankingItemDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final int quantitySold;
  final double revenue;

  const MedicineRankingItemDto({
    required this.medicineId,
    required this.medicineName,
    required this.quantitySold,
    required this.revenue,
  });

  factory MedicineRankingItemDto.fromJson(Map<String, dynamic> json) =>
      MedicineRankingItemDto(
        medicineId: json['medicineId'].toString(),
        medicineName: json['medicineName']?.toString() ?? '',
        quantitySold: json['quantitySold'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [medicineId, medicineName, quantitySold, revenue];
}
