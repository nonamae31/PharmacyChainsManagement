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

final class PaymentTransactionsRequested extends StaffSalesEvent {}

final class InvoiceSubmitted extends StaffSalesEvent {
  final List<InvoiceLineRequestDto> items;
  const InvoiceSubmitted(this.items);
  @override
  List<Object?> get props => [items];
}

final class PaymentSubmitted extends StaffSalesEvent {
  final String invoiceId;
  final String paymentMethod;
  const PaymentSubmitted(this.invoiceId, this.paymentMethod);
  @override
  List<Object?> get props => [invoiceId, paymentMethod];
}
