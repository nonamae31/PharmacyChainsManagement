import 'package:equatable/equatable.dart';

class StocktakeItemDto extends Equatable {
  final String medicineId;
  final String batchId;
  final int physicalQuantity;

  const StocktakeItemDto({
    required this.medicineId,
    required this.batchId,
    required this.physicalQuantity,
  });

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'batchId': batchId,
        'physicalQuantity': physicalQuantity,
      };

  @override
  List<Object?> get props => [medicineId, batchId, physicalQuantity];
}

class StocktakeRequestDto extends Equatable {
  final String branchId;
  final String stocktakeDate; // ISO8601 string
  final String? notes;
  final List<StocktakeItemDto> items;

  const StocktakeRequestDto({
    required this.branchId,
    required this.stocktakeDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'stocktakeDate': stocktakeDate,
        'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [branchId, stocktakeDate, notes, items];
}
