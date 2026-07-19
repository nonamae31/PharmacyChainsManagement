import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions.dart';
import '../entity/staff_sales_dto.dart';
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
    on<InvoiceDetailRequested>(
      (event, emit) => _run(
        emit,
        () async => InvoiceDetailLoadSuccess(
          await _apiClient.getInvoice(event.invoiceId),
        ),
      ),
    );
    on<PaymentTransactionsRequested>(
      (event, emit) => _run(
        emit,
        () async =>
            PaymentTransactionsLoadSuccess(await _apiClient.getPayments()),
      ),
    );
    on<InvoiceDraftStarted>((event, emit) {
      final lines = event.initialMedicine == null
          ? <InvoiceDraftLineModel>[]
          : [
              InvoiceDraftLineModel(
                medicine: event.initialMedicine!,
                quantity: 1,
              ),
            ];
      _emitDraft(emit, lines);
    });
    on<InvoiceMedicineAdded>((event, emit) {
      final lines = _draftLines(state);
      final index = lines.indexWhere(
        (line) => line.medicine.medicineId == event.medicine.medicineId,
      );
      if (index < 0) {
        _emitDraft(emit, [
          ...lines,
          InvoiceDraftLineModel(medicine: event.medicine, quantity: 1),
        ]);
        return;
      }
      final nextQuantity = lines[index].quantity + 1;
      if (nextQuantity > event.medicine.availableQuantity) {
        _emitValidationFailure(
          emit,
          lines,
          AppStrings.insufficientMedicineStock,
        );
        return;
      }
      final updated = [...lines];
      updated[index] = updated[index].copyWith(quantity: nextQuantity);
      _emitDraft(emit, updated);
    });
    on<InvoiceMedicineRemoved>((event, emit) {
      _emitDraft(
        emit,
        _draftLines(state)
            .where((line) => line.medicine.medicineId != event.medicineId)
            .toList(),
      );
    });
    on<InvoiceMedicineQuantityChanged>((event, emit) {
      final lines = _draftLines(state);
      final index = lines.indexWhere(
        (line) => line.medicine.medicineId == event.medicineId,
      );
      if (index < 0) return;
      final quantity = int.tryParse(event.quantity);
      if (quantity == null || quantity < 1) {
        _emitValidationFailure(emit, lines, AppStrings.invalidMedicineQuantity);
        return;
      }
      if (quantity > lines[index].medicine.availableQuantity) {
        _emitValidationFailure(
          emit,
          lines,
          AppStrings.insufficientMedicineStock,
        );
        return;
      }
      final updated = [...lines];
      updated[index] = updated[index].copyWith(quantity: quantity);
      _emitDraft(emit, updated);
    });
    on<InvoiceSubmitted>((event, emit) async {
      final lines = _draftLines(state);
      if (lines.isEmpty) {
        _emitValidationFailure(emit, lines, AppStrings.invoiceRequiresMedicine);
        return;
      }
      final total = _draftTotal(lines);
      emit(InvoiceSubmitting(lines, total));
      try {
        final requestItems = lines
            .map(
              (line) => InvoiceLineRequestDto(
                medicineId: line.medicine.medicineId,
                quantity: line.quantity,
              ),
            )
            .toList();
        emit(
          InvoiceSubmitSuccess(await _apiClient.createInvoice(requestItems)),
        );
      } on AppException catch (error) {
        emit(InvoiceSubmitFailure(lines, total, error.message));
      } catch (_) {
        emit(InvoiceSubmitFailure(lines, total, AppStrings.unknownError));
      }
    });
    on<PaymentSubmitted>(
      (event, emit) => _run(
        emit,
        () async => PaymentSubmitSuccess(
          await _apiClient.createPayment(
            event.invoiceId,
            CreatePaymentRequestDto(paymentMethod: event.paymentMethod),
          ),
        ),
      ),
    );
    on<PaymentStatusRequested>((event, emit) async {
      emit(PaymentStatusRefreshInProgress(event.payment));
      try {
        emit(
          PaymentStatusLoadSuccess(
            await _apiClient.getPayment(event.payment.paymentId),
          ),
        );
      } on AppException catch (error) {
        emit(PaymentStatusRefreshFailure(event.payment, error.message));
      } catch (_) {
        emit(
          PaymentStatusRefreshFailure(
            event.payment,
            'Đã có lỗi không xác định.',
          ),
        );
      }
    });
  }

  List<InvoiceDraftLineModel> _draftLines(StaffSalesState currentState) =>
      switch (currentState) {
        InvoiceDraftReady(:final lines) => [...lines],
        InvoiceDraftValidationFailure(:final lines) => [...lines],
        InvoiceSubmitting(:final lines) => [...lines],
        InvoiceSubmitFailure(:final lines) => [...lines],
        _ => <InvoiceDraftLineModel>[],
      };

  double _draftTotal(List<InvoiceDraftLineModel> lines) =>
      lines.fold(0, (total, line) => total + line.lineTotal);

  void _emitDraft(
    Emitter<StaffSalesState> emit,
    List<InvoiceDraftLineModel> lines,
  ) {
    emit(InvoiceDraftReady(List.unmodifiable(lines), _draftTotal(lines)));
  }

  void _emitValidationFailure(
    Emitter<StaffSalesState> emit,
    List<InvoiceDraftLineModel> lines,
    String message,
  ) {
    emit(
      InvoiceDraftValidationFailure(
        List.unmodifiable(lines),
        _draftTotal(lines),
        message,
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
