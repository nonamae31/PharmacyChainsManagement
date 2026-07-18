import 'package:equatable/equatable.dart';

sealed class ReceiveGoodsState extends Equatable {
  const ReceiveGoodsState();
  
  @override
  List<Object?> get props => [];
}

final class ReceiveGoodsInitial extends ReceiveGoodsState {}

final class ReceiveGoodsLoading extends ReceiveGoodsState {}

final class ReceiveGoodsSuccess extends ReceiveGoodsState {}

final class ReceiveGoodsFailure extends ReceiveGoodsState {
  final String message;

  const ReceiveGoodsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
