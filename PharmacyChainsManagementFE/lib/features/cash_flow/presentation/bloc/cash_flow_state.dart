import 'package:equatable/equatable.dart';
import '../../domain/entities/cash_flow_statistics_entity.dart';

abstract class CashFlowState extends Equatable {
  const CashFlowState();

  @override
  List<Object?> get props => [];
}

class CashFlowInitial extends CashFlowState {}

class CashFlowLoading extends CashFlowState {}

class CashFlowLoaded extends CashFlowState {
  final CashFlowStatisticsEntity cashFlow;

  const CashFlowLoaded({required this.cashFlow});

  @override
  List<Object?> get props => [cashFlow];
}

class CashFlowError extends CashFlowState {
  final String message;

  const CashFlowError({required this.message});

  @override
  List<Object?> get props => [message];
}
