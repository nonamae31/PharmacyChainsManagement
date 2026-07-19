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

  const MedicineDto({
    required this.medicineId,
    required this.medicineName,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.availableQuantity,
    required this.safetyStockLevel,
    required this.stockStatus,
  });

  factory MedicineDto.fromJson(Map<String, dynamic> json) => MedicineDto(
    medicineId: json['medicineId'] as String,
    medicineName: json['medicineName'] as String,
    category: json['category'] as String?,
    unit: json['unit'] as String,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    availableQuantity: json['availableQuantity'] as int,
    safetyStockLevel: json['safetyStockLevel'] as int,
    stockStatus: json['stockStatus'] as String,
  );
  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    category,
    unit,
    unitPrice,
    availableQuantity,
    safetyStockLevel,
    stockStatus,
  ];
}

class InvoiceLineRequestDto extends Equatable {
  final String medicineId;
  final int quantity;
  const InvoiceLineRequestDto({
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

class InvoiceDraftLineModel extends Equatable {
  final MedicineDto medicine;
  final int quantity;

  const InvoiceDraftLineModel({required this.medicine, required this.quantity});

  double get lineTotal => medicine.unitPrice * quantity;

  InvoiceDraftLineModel copyWith({int? quantity}) => InvoiceDraftLineModel(
    medicine: medicine,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [medicine, quantity];
}

class InvoiceLineDto extends Equatable {
  final String medicineId;
  final String medicineName;
  final String batchNumber;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  const InvoiceLineDto({
    required this.medicineId,
    required this.medicineName,
    required this.batchNumber,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
  factory InvoiceLineDto.fromJson(Map<String, dynamic> json) => InvoiceLineDto(
    medicineId: json['medicineId'] as String,
    medicineName: json['medicineName'] as String,
    batchNumber: json['batchNumber'] as String,
    quantity: json['quantity'] as int,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    lineTotal: (json['lineTotal'] as num).toDouble(),
  );
  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    batchNumber,
    quantity,
    unitPrice,
    lineTotal,
  ];
}

class InvoiceDto extends Equatable {
  final String invoiceId;
  final String invoiceCode;
  final String invoiceDate;
  final double totalAmount;
  final String paymentStatus;
  final String status;
  final List<InvoiceLineDto> items;
  const InvoiceDto({
    required this.invoiceId,
    required this.invoiceCode,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentStatus,
    required this.status,
    required this.items,
  });
  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
    invoiceId: json['invoiceId'] as String,
    invoiceCode: json['invoiceCode'] as String,
    invoiceDate: json['invoiceDate'] as String,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paymentStatus: (json['paymentStatus'] as String).toUpperCase(),
    status: (json['status'] as String).toUpperCase(),
    items: ((json['items'] as List?) ?? [])
        .map((item) => InvoiceLineDto.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
  @override
  List<Object?> get props => [
    invoiceId,
    invoiceCode,
    invoiceDate,
    totalAmount,
    paymentStatus,
    status,
    items,
  ];
}

class InvoiceSummaryDto extends Equatable {
  final String invoiceId;
  final String invoiceCode;
  final String invoiceDate;
  final double totalAmount;
  final String paymentStatus;
  final String status;
  final int itemCount;
  const InvoiceSummaryDto({
    required this.invoiceId,
    required this.invoiceCode,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentStatus,
    required this.status,
    required this.itemCount,
  });
  factory InvoiceSummaryDto.fromJson(Map<String, dynamic> json) =>
      InvoiceSummaryDto(
        invoiceId: json['invoiceId'] as String,
        invoiceCode: json['invoiceCode'] as String,
        invoiceDate: json['invoiceDate'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentStatus: (json['paymentStatus'] as String).toUpperCase(),
        status: (json['status'] as String).toUpperCase(),
        itemCount: json['itemCount'] as int,
      );
  @override
  List<Object?> get props => [
    invoiceId,
    invoiceCode,
    invoiceDate,
    totalAmount,
    paymentStatus,
    status,
    itemCount,
  ];
}

class PaymentDto extends Equatable {
  final String paymentId;
  final String invoiceId;
  final String invoiceCode;
  final double amount;
  final double? exchangeRate;
  final double? expectedAmountVnd;
  final double? receivedAmountVnd;
  final String baseCurrency;
  final String settlementCurrency;
  final String paymentMethod;
  final String paymentStatus;
  final String? qrCodeUrl;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? transferContent;
  final DateTime? expiresAt;

  const PaymentDto({
    required this.paymentId,
    required this.invoiceId,
    required this.invoiceCode,
    required this.amount,
    required this.exchangeRate,
    required this.expectedAmountVnd,
    required this.receivedAmountVnd,
    required this.baseCurrency,
    required this.settlementCurrency,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.qrCodeUrl,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.transferContent,
    required this.expiresAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) => PaymentDto(
    paymentId: json['paymentId'] as String,
    invoiceId: json['invoiceId'] as String,
    invoiceCode: json['invoiceCode'] as String,
    amount: (json['amount'] as num).toDouble(),
    exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
    expectedAmountVnd: (json['expectedAmountVnd'] as num?)?.toDouble(),
    receivedAmountVnd: (json['receivedAmountVnd'] as num?)?.toDouble(),
    baseCurrency: json['baseCurrency'] as String,
    settlementCurrency: json['settlementCurrency'] as String,
    paymentMethod: (json['paymentMethod'] as String).toUpperCase(),
    paymentStatus: (json['paymentStatus'] as String).toUpperCase(),
    qrCodeUrl: json['qrCodeUrl'] as String?,
    bankName: json['bankName'] as String?,
    accountName: json['accountName'] as String?,
    accountNumber: json['accountNumber'] as String?,
    transferContent: json['transferContent'] as String?,
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String).toLocal(),
  );

  @override
  List<Object?> get props => [
    paymentId,
    invoiceId,
    invoiceCode,
    amount,
    exchangeRate,
    expectedAmountVnd,
    receivedAmountVnd,
    baseCurrency,
    settlementCurrency,
    paymentMethod,
    paymentStatus,
    qrCodeUrl,
    bankName,
    accountName,
    accountNumber,
    transferContent,
    expiresAt,
  ];
}

class CreatePaymentRequestDto extends Equatable {
  final String paymentMethod;

  const CreatePaymentRequestDto({required this.paymentMethod});

  Map<String, dynamic> toJson() => {'paymentMethod': paymentMethod};

  @override
  List<Object?> get props => [paymentMethod];
}

class StaffDashboardDto extends Equatable {
  final double todayRevenue;
  final int todayInvoiceCount;
  final int pendingInvoiceCount;
  final int lowStockItemCount;
  final String shiftLabel;
  const StaffDashboardDto({
    required this.todayRevenue,
    required this.todayInvoiceCount,
    required this.pendingInvoiceCount,
    required this.lowStockItemCount,
    required this.shiftLabel,
  });
  factory StaffDashboardDto.fromJson(Map<String, dynamic> json) =>
      StaffDashboardDto(
        todayRevenue: (json['todayRevenue'] as num).toDouble(),
        todayInvoiceCount: json['todayInvoiceCount'] as int,
        pendingInvoiceCount: json['pendingInvoiceCount'] as int,
        lowStockItemCount: json['lowStockItemCount'] as int,
        shiftLabel: json['shiftLabel'] as String,
      );
  @override
  List<Object?> get props => [
    todayRevenue,
    todayInvoiceCount,
    pendingInvoiceCount,
    lowStockItemCount,
    shiftLabel,
  ];
}
