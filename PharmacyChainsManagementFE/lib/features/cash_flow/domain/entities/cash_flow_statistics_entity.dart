import 'package:equatable/equatable.dart';

class CashFlowStatisticsEntity extends Equatable {
  final double totalInflow;
  final double totalOutflow;
  final double netCashFlow;
  final List<CashFlowDailyDataEntity> dailyData;

  const CashFlowStatisticsEntity({
    required this.totalInflow,
    required this.totalOutflow,
    required this.netCashFlow,
    required this.dailyData,
  });

  @override
  List<Object?> get props => [totalInflow, totalOutflow, netCashFlow, dailyData];
}

class CashFlowDailyDataEntity extends Equatable {
  final DateTime date;
  final double inflow;
  final double outflow;

  const CashFlowDailyDataEntity({
    required this.date,
    required this.inflow,
    required this.outflow,
  });

  @override
  List<Object?> get props => [date, inflow, outflow];
}
