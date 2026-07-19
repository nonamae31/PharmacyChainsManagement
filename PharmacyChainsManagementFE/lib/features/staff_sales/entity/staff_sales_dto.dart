import 'package:equatable/equatable.dart';

class MedicineDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final String? category;
  final String unit;
  final double unitPrice;
  final int availableQuantity;
  final int safetyStockLevel;
  final String stockStatus;

  const MedicineDto({required this.medicineId, required this.medicineName, required this.category, required this.unit, required this.unitPrice, required this.availableQuantity, required this.safetyStockLevel, required this.stockStatus});

  factory MedicineDto.fromJson(Map<String, dynamic> json) => MedicineDto(medicineId: json['medicineId'] as String, medicineName: json['medicineName'] as String, category: json['category'] as String?, unit: json['unit'] as String, unitPrice: (json['unitPrice'] as num).toDouble(), availableQuantity: json['availableQuantity'] as int, safetyStockLevel: json['safetyStockLevel'] as int, stockStatus: json['stockStatus'] as String);
  @override List<Object?> get props => [medicineId, medicineName, category, unit, unitPrice, availableQuantity, safetyStockLevel, stockStatus];
}

class InvoiceLineRequestDto extends Equatable {
  final String medicineId;
  final int quantity;
  const InvoiceLineRequestDto({required this.medicineId, required this.quantity});
  Map<String, dynamic> toJson() => {'medicineId': medicineId, 'quantity': quantity};
  @override List<Object?> get props => [medicineId, quantity];
}

class InvoiceLineDto extends Equatable {
  final String medicineName;
  final int quantity;
  final double lineTotal;
  const InvoiceLineDto({required this.medicineName, required this.quantity, required this.lineTotal});
  factory InvoiceLineDto.fromJson(Map<String, dynamic> json) => InvoiceLineDto(medicineName: json['medicineName'] as String, quantity: json['quantity'] as int, lineTotal: (json['lineTotal'] as num).toDouble());
  @override List<Object?> get props => [medicineName, quantity, lineTotal];
}

class InvoiceDto extends Equatable {
  final String invoiceId;
  final String invoiceCode;
  final String invoiceDate;
  final double totalAmount;
  final String paymentStatus;
  final List<InvoiceLineDto> items;
  const InvoiceDto({required this.invoiceId, required this.invoiceCode, required this.invoiceDate, required this.totalAmount, required this.paymentStatus, required this.items});
  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(invoiceId: json['invoiceId'] as String, invoiceCode: json['invoiceCode'] as String, invoiceDate: json['invoiceDate'] as String, totalAmount: (json['totalAmount'] as num).toDouble(), paymentStatus: json['paymentStatus'] as String, items: ((json['items'] as List?) ?? []).map((item) => InvoiceLineDto.fromJson(item as Map<String, dynamic>)).toList());
  @override List<Object?> get props => [invoiceId, invoiceCode, invoiceDate, totalAmount, paymentStatus, items];
}

class InvoiceSummaryDto extends Equatable {
  final String invoiceId;
  final String invoiceCode;
  final String invoiceDate;
  final double totalAmount;
  final String paymentStatus;
  final int itemCount;
  const InvoiceSummaryDto({required this.invoiceId, required this.invoiceCode, required this.invoiceDate, required this.totalAmount, required this.paymentStatus, required this.itemCount});
  factory InvoiceSummaryDto.fromJson(Map<String, dynamic> json) => InvoiceSummaryDto(invoiceId: json['invoiceId'] as String, invoiceCode: json['invoiceCode'] as String, invoiceDate: json['invoiceDate'] as String, totalAmount: (json['totalAmount'] as num).toDouble(), paymentStatus: json['paymentStatus'] as String, itemCount: json['itemCount'] as int);
  @override List<Object?> get props => [invoiceId, invoiceCode, invoiceDate, totalAmount, paymentStatus, itemCount];
}

class PaymentDto extends Equatable {
  final String paymentId;
  final String invoiceId;
  final String invoiceCode;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  const PaymentDto({required this.paymentId, required this.invoiceId, required this.invoiceCode, required this.amount, required this.paymentMethod, required this.paymentStatus});
  factory PaymentDto.fromJson(Map<String, dynamic> json) => PaymentDto(paymentId: json['paymentId'] as String, invoiceId: json['invoiceId'] as String, invoiceCode: json['invoiceCode'] as String, amount: (json['amount'] as num).toDouble(), paymentMethod: json['paymentMethod'] as String, paymentStatus: json['paymentStatus'] as String);
  @override List<Object?> get props => [paymentId, invoiceId, invoiceCode, amount, paymentMethod, paymentStatus];
}

class StaffDashboardDto extends Equatable {
  final double todayRevenue;
  final int todayInvoiceCount;
  final int pendingInvoiceCount;
  final int lowStockItemCount;
  final String shiftLabel;
  const StaffDashboardDto({required this.todayRevenue, required this.todayInvoiceCount, required this.pendingInvoiceCount, required this.lowStockItemCount, required this.shiftLabel});
  factory StaffDashboardDto.fromJson(Map<String, dynamic> json) => StaffDashboardDto(todayRevenue: (json['todayRevenue'] as num).toDouble(), todayInvoiceCount: json['todayInvoiceCount'] as int, pendingInvoiceCount: json['pendingInvoiceCount'] as int, lowStockItemCount: json['lowStockItemCount'] as int, shiftLabel: json['shiftLabel'] as String);
  @override List<Object?> get props => [todayRevenue, todayInvoiceCount, pendingInvoiceCount, lowStockItemCount, shiftLabel];
}
