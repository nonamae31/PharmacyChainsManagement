import 'package:equatable/equatable.dart';

class CashFlowStatisticsEntity extends Equatable {
  final double totalInflow;
  final double totalOutflow;
  final double netCashFlow;
  final List<CashFlowDailyDataEntity> dailyData;
  final List<RecentTransactionEntity> recentTransactions;
  final List<LiquidityForecastEntity> liquidityForecasts;
  final List<BudgetAllocationEntity> budgetAllocations;

  const CashFlowStatisticsEntity({
    required this.totalInflow,
    required this.totalOutflow,
    required this.netCashFlow,
    required this.dailyData,
    required this.recentTransactions,
    required this.liquidityForecasts,
    required this.budgetAllocations,
  });

  @override
  List<Object?> get props => [
        totalInflow,
        totalOutflow,
        netCashFlow,
        dailyData,
        recentTransactions,
        liquidityForecasts,
        budgetAllocations,
      ];
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

class RecentTransactionEntity extends Equatable {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;

  const RecentTransactionEntity({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [id, date, description, amount, type];
}

class LiquidityForecastEntity extends Equatable {
  final String month;
  final double projectedInflow;
  final double projectedOutflow;

  const LiquidityForecastEntity({
    required this.month,
    required this.projectedInflow,
    required this.projectedOutflow,
  });

  @override
  List<Object?> get props => [month, projectedInflow, projectedOutflow];
}

class BudgetAllocationEntity extends Equatable {
  final String categoryName;
  final double percentage;

  const BudgetAllocationEntity({
    required this.categoryName,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryName, percentage];
}
