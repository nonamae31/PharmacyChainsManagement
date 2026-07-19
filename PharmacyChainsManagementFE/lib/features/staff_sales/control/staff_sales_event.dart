import 'package:equatable/equatable.dart';
import '../entity/staff_sales_dto.dart';

sealed class StaffSalesEvent extends Equatable {
  const StaffSalesEvent();
  @override
  List<Object?> get props => [];
}

final class StaffDashboardRequested extends StaffSalesEvent {}

final class MedicineSearchRequested extends StaffSalesEvent {
  final String? search;
  const MedicineSearchRequested(this.search);
  @override
  List<Object?> get props => [search];
}

final class InvoiceHistoryRequested extends StaffSalesEvent {}

final class InvoiceDetailRequested extends StaffSalesEvent {
  final String invoiceId;
  const InvoiceDetailRequested(this.invoiceId);
  @override
  List<Object?> get props => [invoiceId];
}

final class PaymentTransactionsRequested extends StaffSalesEvent {}

final class InvoiceDraftStarted extends StaffSalesEvent {
  final MedicineDto? initialMedicine;
  const InvoiceDraftStarted(this.initialMedicine);
  @override
  List<Object?> get props => [initialMedicine];
}

final class InvoiceMedicineAdded extends StaffSalesEvent {
  final MedicineDto medicine;
  const InvoiceMedicineAdded(this.medicine);
  @override
  List<Object?> get props => [medicine];
}

final class InvoiceMedicineRemoved extends StaffSalesEvent {
  final String medicineId;
  const InvoiceMedicineRemoved(this.medicineId);
  @override
  List<Object?> get props => [medicineId];
}

final class InvoiceMedicineQuantityChanged extends StaffSalesEvent {
  final String medicineId;
  final String quantity;
  const InvoiceMedicineQuantityChanged(this.medicineId, this.quantity);
  @override
  List<Object?> get props => [medicineId, quantity];
}

final class InvoiceSubmitted extends StaffSalesEvent {
  const InvoiceSubmitted();
}

final class PaymentSubmitted extends StaffSalesEvent {
  final String invoiceId;
  final String paymentMethod;
  const PaymentSubmitted(this.invoiceId, this.paymentMethod);
  @override
  List<Object?> get props => [invoiceId, paymentMethod];
}

final class PaymentStatusRequested extends StaffSalesEvent {
  final PaymentDto payment;
  const PaymentStatusRequested(this.payment);
  @override
  List<Object?> get props => [payment];
}
