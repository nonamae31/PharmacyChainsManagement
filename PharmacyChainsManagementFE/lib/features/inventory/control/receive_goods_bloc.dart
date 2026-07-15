import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/inventory_api_client.dart';
import 'receive_goods_event.dart';
import 'receive_goods_state.dart';

class ReceiveGoodsBloc extends Bloc<ReceiveGoodsEvent, ReceiveGoodsState> {
  final InventoryApiClient _apiClient;

  ReceiveGoodsBloc(this._apiClient) : super(ReceiveGoodsInitial()) {
    on<ReceiveGoodsSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ReceiveGoodsSubmitted event,
    Emitter<ReceiveGoodsState> emit,
  ) async {
    emit(ReceiveGoodsLoading());
    try {
      await _apiClient.receiveGoods(event.request);
      emit(ReceiveGoodsSuccess());
    } on AppException catch (e) {
      emit(ReceiveGoodsFailure(e.message));
    } catch (e) {
      emit(const ReceiveGoodsFailure('Đã có lỗi không xác định xảy ra.'));
    }
  }
}
