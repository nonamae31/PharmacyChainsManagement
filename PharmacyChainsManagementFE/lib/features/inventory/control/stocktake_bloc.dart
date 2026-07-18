import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/inventory_api_client.dart';
import 'stocktake_event.dart';
import 'stocktake_state.dart';

class StocktakeBloc extends Bloc<StocktakeEvent, StocktakeState> {
  final InventoryApiClient _apiClient;

  StocktakeBloc(this._apiClient) : super(StocktakeInitial()) {
    on<StocktakeSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    StocktakeSubmitted event,
    Emitter<StocktakeState> emit,
  ) async {
    emit(StocktakeLoading());
    try {
      await _apiClient.submitStocktake(event.request);
      emit(StocktakeSuccess());
    } on AppException catch (e) {
      emit(StocktakeFailure(e.message));
    } catch (e) {
      emit(StocktakeFailure('Lỗi hệ thống: ${e.toString()}'));
    }
  }
}
