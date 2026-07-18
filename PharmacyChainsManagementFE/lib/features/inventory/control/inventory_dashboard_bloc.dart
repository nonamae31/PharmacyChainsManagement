import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/inventory_api_client.dart';
import 'inventory_dashboard_event.dart';
import 'inventory_dashboard_state.dart';

class InventoryDashboardBloc extends Bloc<InventoryDashboardEvent, InventoryDashboardState> {
  final InventoryApiClient _apiClient;

  InventoryDashboardBloc(this._apiClient) : super(InventoryDashboardInitial()) {
    on<InventoryDashboardFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    InventoryDashboardFetchRequested event,
    Emitter<InventoryDashboardState> emit,
  ) async {
    emit(InventoryDashboardLoading());
    try {
      final valuation = await _apiClient.getInventoryValuation(event.branchId);
      emit(InventoryDashboardLoadSuccess(valuation));
    } on AppException catch (e) {
      emit(InventoryDashboardLoadFailure(e.message));
    } catch (e) {
      emit(InventoryDashboardLoadFailure('Lỗi hệ thống: ${e.toString()}'));
    }
  }
}
