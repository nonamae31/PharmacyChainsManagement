import '../../domain/entities/cash_flow_statistics_entity.dart';

class CashFlowModel extends CashFlowStatisticsEntity {
  const CashFlowModel({
    required super.totalInflow,
    required super.totalOutflow,
    required super.netCashFlow,
    required super.dailyData,
    required super.recentTransactions,
    required super.liquidityForecasts,
    required super.budgetAllocations,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      totalInflow: (json['totalInflow'] as num?)?.toDouble() ?? 0.0,
      totalOutflow: (json['totalOutflow'] as num?)?.toDouble() ?? 0.0,
      netCashFlow: (json['netCashFlow'] as num?)?.toDouble() ?? 0.0,
      dailyData: (json['dailyData'] as List<dynamic>?)
              ?.map((e) => CashFlowDailyDataModel.fromJson(e))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => RecentTransactionModel.fromJson(e))
              .toList() ??
          [],
      liquidityForecasts: (json['liquidityForecasts'] as List<dynamic>?)
              ?.map((e) => LiquidityForecastModel.fromJson(e))
              .toList() ??
          [],
      budgetAllocations: (json['budgetAllocations'] as List<dynamic>?)
              ?.map((e) => BudgetAllocationModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInflow': totalInflow,
      'totalOutflow': totalOutflow,
      'netCashFlow': netCashFlow,
      'dailyData': dailyData.map((e) => (e as CashFlowDailyDataModel).toJson()).toList(),
      'recentTransactions': recentTransactions.map((e) => (e as RecentTransactionModel).toJson()).toList(),
      'liquidityForecasts': liquidityForecasts.map((e) => (e as LiquidityForecastModel).toJson()).toList(),
      'budgetAllocations': budgetAllocations.map((e) => (e as BudgetAllocationModel).toJson()).toList(),
    };
  }
}

class CashFlowDailyDataModel extends CashFlowDailyDataEntity {
  const CashFlowDailyDataModel({
    required super.date,
    required super.inflow,
    required super.outflow,
  });

  factory CashFlowDailyDataModel.fromJson(Map<String, dynamic> json) {
    return CashFlowDailyDataModel(
      date: DateTime.parse(json['date'] as String),
      inflow: (json['inflow'] as num?)?.toDouble() ?? 0.0,
      outflow: (json['outflow'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'inflow': inflow,
      'outflow': outflow,
    };
  }
}

class RecentTransactionModel extends RecentTransactionEntity {
  const RecentTransactionModel({
    required super.id,
    required super.date,
    required super.description,
    required super.amount,
    required super.type,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
    };
  }
}

class LiquidityForecastModel extends LiquidityForecastEntity {
  const LiquidityForecastModel({
    required super.month,
    required super.projectedInflow,
    required super.projectedOutflow,
  });

  factory LiquidityForecastModel.fromJson(Map<String, dynamic> json) {
    return LiquidityForecastModel(
      month: json['month'] as String? ?? '',
      projectedInflow: (json['projectedInflow'] as num?)?.toDouble() ?? 0.0,
      projectedOutflow: (json['projectedOutflow'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'projectedInflow': projectedInflow,
      'projectedOutflow': projectedOutflow,
    };
  }
}

class BudgetAllocationModel extends BudgetAllocationEntity {
  const BudgetAllocationModel({
    required super.categoryName,
    required super.percentage,
  });

  factory BudgetAllocationModel.fromJson(Map<String, dynamic> json) {
    return BudgetAllocationModel(
      categoryName: json['categoryName'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'percentage': percentage,
    };
  }
}
