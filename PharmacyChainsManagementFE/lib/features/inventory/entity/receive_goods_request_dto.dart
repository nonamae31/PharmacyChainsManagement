import 'package:equatable/equatable.dart';

class ReceiveGoodsItemDto extends Equatable {
  final String medicineId;
  final String batchNo;
  final String expiryDate; // Using ISO8601 string for DateTime
  final int quantity;

  const ReceiveGoodsItemDto({
    required this.medicineId,
    required this.batchNo,
    required this.expiryDate,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'batchNo': batchNo,
        'expiryDate': expiryDate,
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [medicineId, batchNo, expiryDate, quantity];
}

class ReceiveGoodsRequestDto extends Equatable {
  final String supplierId;
  final String? poId;
  final String? deliveryNoteNo;
  final String receivedDate; // Using ISO8601 string for DateTime
  final List<ReceiveGoodsItemDto> items;

  const ReceiveGoodsRequestDto({
    required this.supplierId,
    this.poId,
    this.deliveryNoteNo,
    required this.receivedDate,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'supplierId': supplierId,
        'poId': poId,
        'deliveryNoteNo': deliveryNoteNo,
        'receivedDate': receivedDate,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        supplierId,
        poId,
        deliveryNoteNo,
        receivedDate,
        items,
      ];
}
