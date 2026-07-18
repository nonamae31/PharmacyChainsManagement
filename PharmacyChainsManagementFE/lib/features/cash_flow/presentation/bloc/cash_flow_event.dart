import 'package:equatable/equatable.dart';

abstract class CashFlowEvent extends Equatable {
  const CashFlowEvent();

  @override
  List<Object?> get props => [];
}

class FetchCashFlowEvent extends CashFlowEvent {
  final String startDate;
  final String endDate;
  final String? branchId;

  const FetchCashFlowEvent({
    required this.startDate,
    required this.endDate,
    this.branchId,
  });

  @override
  List<Object?> get props => [startDate, endDate, branchId];
}
