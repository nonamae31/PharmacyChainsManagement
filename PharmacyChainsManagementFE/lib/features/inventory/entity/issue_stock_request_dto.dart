import 'package:equatable/equatable.dart';

class IssueStockItemDto extends Equatable {
  final String medicineId;
  final int quantity;

  const IssueStockItemDto({
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

class IssueStockRequestDto extends Equatable {
  final String storeId;
  final String requestNo;
  final List<IssueStockItemDto> items;

  const IssueStockRequestDto({
    required this.storeId,
    required this.requestNo,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'requestNo': requestNo,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [storeId, requestNo, items];
}
