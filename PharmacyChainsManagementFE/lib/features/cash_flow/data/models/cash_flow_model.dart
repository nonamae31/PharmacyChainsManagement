import '../../domain/entities/cash_flow_statistics_entity.dart';

class CashFlowModel extends CashFlowStatisticsEntity {
  const CashFlowModel({
    required super.totalInflow,
    required super.totalOutflow,
    required super.netCashFlow,
    required super.dailyData,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInflow': totalInflow,
      'totalOutflow': totalOutflow,
      'netCashFlow': netCashFlow,
      'dailyData': dailyData.map((e) => (e as CashFlowDailyDataModel).toJson()).toList(),
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
