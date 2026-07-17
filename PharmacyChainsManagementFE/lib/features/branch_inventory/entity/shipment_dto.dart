import 'package:equatable/equatable.dart';

class TransferSourceBranchDto extends Equatable {
  final String branchId;
  final String branchName;

  const TransferSourceBranchDto({
    required this.branchId,
    required this.branchName,
  });

  factory TransferSourceBranchDto.fromJson(Map<String, dynamic> json) =>
      TransferSourceBranchDto(
        branchId: json['branchId'].toString(),
        branchName: json['branchName']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [branchId, branchName];
}

class TransferBatchOptionDto extends Equatable {
  final String branchId;
  final String medicineId;
  final String batchId;
  final String medicineName;
  final String batchNumber;
  final int availableQuantity;
  final DateTime expiryDate;

  const TransferBatchOptionDto({
    required this.branchId,
    required this.medicineId,
    required this.batchId,
    required this.medicineName,
    required this.batchNumber,
    required this.availableQuantity,
    required this.expiryDate,
  });

  factory TransferBatchOptionDto.fromJson(Map<String, dynamic> json) =>
      TransferBatchOptionDto(
        branchId: json['branchId'].toString(),
        medicineId: json['medicineId'].toString(),
        batchId: json['batchId'].toString(),
        medicineName: json['medicineName']?.toString() ?? '',
        batchNumber: json['batchNumber']?.toString() ?? '',
        availableQuantity: (json['availableQuantity'] as num?)?.toInt() ?? 0,
        expiryDate: DateTime.parse(json['expiryDate'].toString()),
      );

  @override
  List<Object?> get props => [
    branchId,
    medicineId,
    batchId,
    medicineName,
    batchNumber,
    availableQuantity,
    expiryDate,
  ];
}

class ShipmentOptionsDto extends Equatable {
  final List<TransferSourceBranchDto> sourceBranches;
  final List<TransferBatchOptionDto> batches;

  const ShipmentOptionsDto({
    required this.sourceBranches,
    required this.batches,
  });

  factory ShipmentOptionsDto.fromJson(Map<String, dynamic> json) =>
      ShipmentOptionsDto(
        sourceBranches: (json['sourceBranches'] as List<dynamic>? ?? const [])
            .map(
              (item) => TransferSourceBranchDto.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
        batches: (json['batches'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  TransferBatchOptionDto.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
      );

  @override
  List<Object?> get props => [sourceBranches, batches];
}

class CreateShipmentRequestDto extends Equatable {
  final String fromBranchId;
  final String batchId;
  final int quantity;
  final String? notes;

  const CreateShipmentRequestDto({
    required this.fromBranchId,
    required this.batchId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'fromBranchId': fromBranchId,
    'batchId': batchId,
    'quantity': quantity,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  @override
  List<Object?> get props => [fromBranchId, batchId, quantity, notes];
}
