import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../network/branch_inventory_api_client.dart';
import 'branch_inventory_event.dart';
import 'branch_inventory_state.dart';

class BranchInventoryBloc
    extends Bloc<BranchInventoryEvent, BranchInventoryState> {
  final BranchInventoryApiClient _apiClient;

  BranchInventoryBloc(this._apiClient) : super(const BranchInventoryInitial()) {
    on<BranchInventoryFetchRequested>(_onFetchRequested);
    on<BranchInventoryExportRequested>(_onExportRequested);
  }

  Future<void> _onFetchRequested(
    BranchInventoryFetchRequested event,
    Emitter<BranchInventoryState> emit,
  ) async {
    emit(const BranchInventoryLoading());
    try {
      emit(
        BranchInventoryLoadSuccess(
          inventory: await _apiClient.fetchInventory(
            search: event.search,
            category: event.category,
            status: event.status,
            page: event.page,
          ),
          search: event.search ?? '',
          category: event.category ?? 'all',
          status: event.status ?? 'all',
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(BranchInventoryLoadFailure(error.message));
    } catch (_) {
      emit(const BranchInventoryLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  Future<void> _onExportRequested(
    BranchInventoryExportRequested event,
    Emitter<BranchInventoryState> emit,
  ) async {
    final current = state;
    if (current is! BranchInventoryLoadSuccess) return;
    try {
      emit(
        BranchInventoryExportSuccess(
          inventory: current.inventory,
          search: current.search,
          category: current.category,
          status: current.status,
          bytes: await _apiClient.exportInventory(),
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(BranchInventoryLoadFailure(error.message));
    } catch (_) {
      emit(const BranchInventoryLoadFailure(AppStrings.dataCannotLoad));
    }
  }
}
