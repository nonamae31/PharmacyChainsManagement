import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/exceptions.dart';
import '../network/staff_sales_api_client.dart';
import 'staff_sales_event.dart';
import 'staff_sales_state.dart';

class StaffSalesBloc extends Bloc<StaffSalesEvent, StaffSalesState> {
  final StaffSalesApiClient _apiClient;
  StaffSalesBloc({required StaffSalesApiClient apiClient})
    : _apiClient = apiClient,
      super(StaffSalesInitial()) {
    on<StaffDashboardRequested>(
      (event, emit) => _run(
        emit,
        () async => StaffDashboardLoadSuccess(await _apiClient.getDashboard()),
      ),
    );
    on<MedicineSearchRequested>(
      (event, emit) => _run(
        emit,
        () async => MedicineSearchLoadSuccess(
          await _apiClient.searchMedicines(search: event.search),
        ),
      ),
    );
    on<InvoiceHistoryRequested>(
      (event, emit) => _run(
        emit,
        () async => InvoiceHistoryLoadSuccess(await _apiClient.getInvoices()),
      ),
    );
    on<PaymentTransactionsRequested>(
      (event, emit) => _run(
        emit,
        () async =>
            PaymentTransactionsLoadSuccess(await _apiClient.getPayments()),
      ),
    );
    on<InvoiceSubmitted>(
      (event, emit) => _run(
        emit,
        () async =>
            InvoiceSubmitSuccess(await _apiClient.createInvoice(event.items)),
      ),
    );
    on<PaymentSubmitted>(
      (event, emit) => _run(
        emit,
        () async => PaymentSubmitSuccess(
          await _apiClient.createPayment(event.invoiceId, event.paymentMethod),
        ),
      ),
    );
  }
  Future<void> _run(
    Emitter<StaffSalesState> emit,
    Future<StaffSalesState> Function() action,
  ) async {
    emit(StaffSalesLoading());
    try {
      emit(await action());
    } on AppException catch (error) {
      emit(StaffSalesLoadFailure(error.message));
    } catch (_) {
      emit(const StaffSalesLoadFailure('Đã có lỗi không xác định.'));
    }
  }
}
