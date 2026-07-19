import 'package:equatable/equatable.dart';
import '../../domain/entities/cash_flow_statistics_entity.dart';
import '../../domain/entities/branch_entity.dart';

abstract class CashFlowState extends Equatable {
  const CashFlowState();

  @override
  List<Object?> get props => [];
}

class CashFlowInitial extends CashFlowState {}

class CashFlowLoading extends CashFlowState {}

class CashFlowLoaded extends CashFlowState {
  final CashFlowStatisticsEntity cashFlow;
  final List<BranchEntity> branches;

  const CashFlowLoaded({required this.cashFlow, required this.branches});

  @override
  List<Object?> get props => [cashFlow, branches];
}

class CashFlowError extends CashFlowState {
  final String message;

  const CashFlowError({required this.message});

  @override
  List<Object?> get props => [message];
}
