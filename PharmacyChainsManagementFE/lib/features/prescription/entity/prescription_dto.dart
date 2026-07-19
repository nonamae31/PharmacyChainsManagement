import 'package:equatable/equatable.dart';

class PrescriptionListItemDto extends Equatable {
  final String prescriptionId;
  final String customerName;
  final String? doctorName;
  final String prescriptionDate;
  final String status;
  final int itemCount;
  const PrescriptionListItemDto({required this.prescriptionId, required this.customerName, required this.doctorName, required this.prescriptionDate, required this.status, required this.itemCount});
  factory PrescriptionListItemDto.fromJson(Map<String, dynamic> json) => PrescriptionListItemDto(prescriptionId: json['prescriptionId'] as String, customerName: json['customerName'] as String, doctorName: json['doctorName'] as String?, prescriptionDate: json['prescriptionDate'] as String, status: json['status'] as String, itemCount: json['itemCount'] as int);
  @override List<Object?> get props => [prescriptionId, customerName, doctorName, prescriptionDate, status, itemCount];
}

class PrescriptionLineDto extends Equatable {
  final String prescriptionDetailId;
  final String medicineId;
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final int quantity;
  const PrescriptionLineDto({required this.prescriptionDetailId, required this.medicineId, required this.medicineName, required this.dosage, required this.frequency, required this.duration, required this.quantity});
  factory PrescriptionLineDto.fromJson(Map<String, dynamic> json) => PrescriptionLineDto(prescriptionDetailId: json['prescriptionDetailId'] as String, medicineId: json['medicineId'] as String, medicineName: json['medicineName'] as String, dosage: json['dosage'] as String?, frequency: json['frequency'] as String?, duration: json['duration'] as String?, quantity: json['quantity'] as int);
  @override List<Object?> get props => [prescriptionDetailId, medicineId, medicineName, dosage, frequency, duration, quantity];
}

class PrescriptionDto extends Equatable {
  final String prescriptionId;
  final String customerName;
  final String? doctorName;
  final String prescriptionDate;
  final String status;
  final List<PrescriptionLineDto> items;
  const PrescriptionDto({required this.prescriptionId, required this.customerName, required this.doctorName, required this.prescriptionDate, required this.status, required this.items});
  factory PrescriptionDto.fromJson(Map<String, dynamic> json) => PrescriptionDto(prescriptionId: json['prescriptionId'] as String, customerName: json['customerName'] as String, doctorName: json['doctorName'] as String?, prescriptionDate: json['prescriptionDate'] as String, status: json['status'] as String, items: ((json['items'] as List?) ?? []).map((item) => PrescriptionLineDto.fromJson(item as Map<String, dynamic>)).toList());
  @override List<Object?> get props => [prescriptionId, customerName, doctorName, prescriptionDate, status, items];
}
