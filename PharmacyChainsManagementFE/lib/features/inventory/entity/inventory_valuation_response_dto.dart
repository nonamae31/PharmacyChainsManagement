import 'package:equatable/equatable.dart';

class InventoryValuationItemDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final int totalAvailableQuantity;
  final double averageCost;
  final double totalValue;

  const InventoryValuationItemDto({
    required this.medicineId,
    required this.medicineName,
    required this.totalAvailableQuantity,
    required this.averageCost,
    required this.totalValue,
  });

  factory InventoryValuationItemDto.fromJson(Map<String, dynamic> json) =>
      InventoryValuationItemDto(
        medicineId: json['medicineId'] as String,
        medicineName: json['medicineName'] as String,
        totalAvailableQuantity: json['totalAvailableQuantity'] as int,
        averageCost: (json['averageCost'] as num).toDouble(),
        totalValue: (json['totalValue'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'totalAvailableQuantity': totalAvailableQuantity,
        'averageCost': averageCost,
        'totalValue': totalValue,
      };

  @override
  List<Object?> get props => [
        medicineId,
        medicineName,
        totalAvailableQuantity,
        averageCost,
        totalValue,
      ];
}

class InventoryValuationResponseDto extends Equatable {
  final double totalValue;
  final List<InventoryValuationItemDto> items;

  const InventoryValuationResponseDto({
    required this.totalValue,
    required this.items,
  });

  factory InventoryValuationResponseDto.fromJson(Map<String, dynamic> json) {
    return InventoryValuationResponseDto(
      totalValue: (json['totalValue'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => InventoryValuationItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalValue': totalValue,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [totalValue, items];
}
