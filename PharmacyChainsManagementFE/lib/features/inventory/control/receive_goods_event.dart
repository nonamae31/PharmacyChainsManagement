import 'package:equatable/equatable.dart';
import '../entity/receive_goods_request_dto.dart';

sealed class ReceiveGoodsEvent extends Equatable {
  const ReceiveGoodsEvent();

  @override
  List<Object?> get props => [];
}

final class ReceiveGoodsSubmitted extends ReceiveGoodsEvent {
  final ReceiveGoodsRequestDto request;

  const ReceiveGoodsSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
