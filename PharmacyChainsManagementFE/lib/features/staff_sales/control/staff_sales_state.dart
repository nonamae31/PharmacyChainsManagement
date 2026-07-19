import 'package:equatable/equatable.dart';
import '../entity/staff_sales_dto.dart';

sealed class StaffSalesState extends Equatable {
  const StaffSalesState();
  @override
  List<Object?> get props => [];
}

final class StaffSalesInitial extends StaffSalesState {}

final class StaffSalesLoading extends StaffSalesState {}

final class StaffDashboardLoadSuccess extends StaffSalesState {
  final StaffDashboardDto dashboard;
  const StaffDashboardLoadSuccess(this.dashboard);
  @override
  List<Object?> get props => [dashboard];
}

final class MedicineSearchLoadSuccess extends StaffSalesState {
  final List<MedicineDto> medicines;
  const MedicineSearchLoadSuccess(this.medicines);
  @override
  List<Object?> get props => [medicines];
}

final class InvoiceHistoryLoadSuccess extends StaffSalesState {
  final List<InvoiceSummaryDto> invoices;
  const InvoiceHistoryLoadSuccess(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

final class PaymentTransactionsLoadSuccess extends StaffSalesState {
  final List<PaymentDto> payments;
  const PaymentTransactionsLoadSuccess(this.payments);
  @override
  List<Object?> get props => [payments];
}

final class InvoiceSubmitSuccess extends StaffSalesState {
  final InvoiceDto invoice;
  const InvoiceSubmitSuccess(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

final class PaymentSubmitSuccess extends StaffSalesState {
  final PaymentDto payment;
  const PaymentSubmitSuccess(this.payment);
  @override
  List<Object?> get props => [payment];
}

final class StaffSalesLoadFailure extends StaffSalesState {
  final String message;
  const StaffSalesLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}
