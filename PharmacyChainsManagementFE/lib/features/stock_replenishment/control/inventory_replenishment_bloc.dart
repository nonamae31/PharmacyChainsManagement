import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/stock_replenishment_api_client.dart';
import 'inventory_replenishment_event.dart';
import 'inventory_replenishment_state.dart';

class InventoryReplenishmentBloc
    extends Bloc<InventoryReplenishmentEvent, InventoryReplenishmentState> {
  final StockReplenishmentApiClient _apiClient;

  InventoryReplenishmentBloc(this._apiClient)
    : super(const InventoryReplenishmentInitial()) {
    on<InventoryReplenishmentFetchRequested>(_onFetchRequested);
    on<InventoryReplenishmentStatusUpdated>(_onStatusUpdated);
    on<InventoryReplenishmentDispatchOptionsRequested>(
      _onDispatchOptionsRequested,
    );
    on<InventoryReplenishmentDispatchSubmitted>(_onDispatchSubmitted);
  }

  Future<void> _onFetchRequested(
    InventoryReplenishmentFetchRequested event,
    Emitter<InventoryReplenishmentState> emit,
  ) async {
    emit(const InventoryReplenishmentLoading());
    try {
      emit(
        InventoryReplenishmentLoadSuccess(
          requests: await _apiClient.fetchInventoryQueue(status: event.status),
          status: event.status,
        ),
      );
    } on AppException catch (error) {
      emit(InventoryReplenishmentLoadFailure(error.message));
    } catch (_) {
      emit(
        const InventoryReplenishmentLoadFailure(
          StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }

  Future<void> _onStatusUpdated(
    InventoryReplenishmentStatusUpdated event,
    Emitter<InventoryReplenishmentState> emit,
  ) async {
    final current = state;
    if (current is! InventoryReplenishmentLoadSuccess || current.updating) {
      return;
    }

    emit(
      InventoryReplenishmentLoadSuccess(
        requests: current.requests,
        status: current.status,
        updating: true,
      ),
    );
    try {
      await _apiClient.updateInventoryStatus(event.requestId, event.request);
      emit(
        InventoryReplenishmentUpdateSuccess(
          requests: await _apiClient.fetchInventoryQueue(
            status: current.status,
          ),
          status: current.status,
        ),
      );
    } on AppException catch (error) {
      emit(
        InventoryReplenishmentUpdateFailure(
          requests: current.requests,
          status: current.status,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        InventoryReplenishmentUpdateFailure(
          requests: current.requests,
          status: current.status,
          message: StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }

  Future<void> _onDispatchOptionsRequested(
    InventoryReplenishmentDispatchOptionsRequested event,
    Emitter<InventoryReplenishmentState> emit,
  ) async {
    final current = state;
    if (current is! InventoryReplenishmentLoadSuccess || current.updating) {
      return;
    }

    emit(
      InventoryReplenishmentLoadSuccess(
        requests: current.requests,
        status: current.status,
        updating: true,
      ),
    );
    try {
      final sources = await _apiClient.fetchDispatchSources(
        event.request.requestId,
      );
      if (sources.isEmpty) {
        emit(
          InventoryReplenishmentDispatchFailure(
            requests: current.requests,
            status: current.status,
            message: StockReplenishmentAppStrings.noDispatchSource,
          ),
        );
        return;
      }
      emit(
        InventoryReplenishmentDispatchOptionsSuccess(
          requests: current.requests,
          status: current.status,
          request: event.request,
          sources: sources,
        ),
      );
    } on AppException catch (error) {
      emit(
        InventoryReplenishmentDispatchFailure(
          requests: current.requests,
          status: current.status,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        InventoryReplenishmentDispatchFailure(
          requests: current.requests,
          status: current.status,
          message: StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }

  Future<void> _onDispatchSubmitted(
    InventoryReplenishmentDispatchSubmitted event,
    Emitter<InventoryReplenishmentState> emit,
  ) async {
    final current = state;
    if (current is! InventoryReplenishmentLoadSuccess || current.updating) {
      return;
    }

    emit(
      InventoryReplenishmentLoadSuccess(
        requests: current.requests,
        status: current.status,
        updating: true,
      ),
    );
    try {
      await _apiClient.dispatchInventoryRequest(event.requestId, event.request);
      emit(
        InventoryReplenishmentDispatchSuccess(
          requests: await _apiClient.fetchInventoryQueue(
            status: current.status,
          ),
          status: current.status,
        ),
      );
    } on AppException catch (error) {
      emit(
        InventoryReplenishmentDispatchFailure(
          requests: current.requests,
          status: current.status,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        InventoryReplenishmentDispatchFailure(
          requests: current.requests,
          status: current.status,
          message: StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }
}
