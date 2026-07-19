import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/inventory_api_client.dart';
import 'issue_stock_event.dart';
import 'issue_stock_state.dart';

class IssueStockBloc extends Bloc<IssueStockEvent, IssueStockState> {
  final InventoryApiClient _apiClient;

  IssueStockBloc(this._apiClient) : super(IssueStockInitial()) {
    on<IssueStockSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    IssueStockSubmitted event,
    Emitter<IssueStockState> emit,
  ) async {
    emit(IssueStockLoading());
    try {
      await _apiClient.issueStock(event.request);
      emit(IssueStockSuccess());
    } on AppException catch (e) {
      emit(IssueStockFailure(e.message));
    } catch (e) {
      emit(IssueStockFailure('Lỗi hệ thống: ${e.toString()}'));
    }
  }
}
