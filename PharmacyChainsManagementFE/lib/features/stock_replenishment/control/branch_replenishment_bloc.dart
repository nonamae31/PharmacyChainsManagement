import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/stock_replenishment_api_client.dart';
import 'branch_replenishment_event.dart';
import 'branch_replenishment_state.dart';

class BranchReplenishmentBloc
    extends Bloc<BranchReplenishmentEvent, BranchReplenishmentState> {
  final StockReplenishmentApiClient _apiClient;

  BranchReplenishmentBloc(this._apiClient)
    : super(const BranchReplenishmentInitial()) {
    on<BranchReplenishmentFetchRequested>(_onFetchRequested);
    on<BranchReplenishmentSubmitted>(_onSubmitted);
  }

  Future<void> _onFetchRequested(
    BranchReplenishmentFetchRequested event,
    Emitter<BranchReplenishmentState> emit,
  ) async {
    emit(const BranchReplenishmentLoading());
    try {
      final options = await _apiClient.fetchBranchOptions();
      final requests = await _apiClient.fetchBranchRequests();
      emit(
        BranchReplenishmentLoadSuccess(options: options, requests: requests),
      );
    } on AppException catch (error) {
      emit(BranchReplenishmentLoadFailure(error.message));
    } catch (_) {
      emit(
        const BranchReplenishmentLoadFailure(
          StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    BranchReplenishmentSubmitted event,
    Emitter<BranchReplenishmentState> emit,
  ) async {
    final current = state;
    if (current is! BranchReplenishmentLoadSuccess || current.submitting) {
      return;
    }

    emit(
      BranchReplenishmentLoadSuccess(
        options: current.options,
        requests: current.requests,
        submitting: true,
      ),
    );
    try {
      final created = await _apiClient.createBranchRequest(event.request);
      final requests = await _apiClient.fetchBranchRequests();
      emit(
        BranchReplenishmentSubmitSuccess(
          options: current.options,
          requests: requests,
          createdRequest: created,
        ),
      );
    } on AppException catch (error) {
      emit(
        BranchReplenishmentSubmitFailure(
          options: current.options,
          requests: current.requests,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        BranchReplenishmentSubmitFailure(
          options: current.options,
          requests: current.requests,
          message: StockReplenishmentAppStrings.dataCannotLoad,
        ),
      );
    }
  }
}
