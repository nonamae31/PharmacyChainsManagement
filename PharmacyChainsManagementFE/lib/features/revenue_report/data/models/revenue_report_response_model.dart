import '../../domain/entities/revenue_report_response.dart';

class RevenueItemModel extends RevenueItem {
  const RevenueItemModel({
    required super.date,
    required super.amount,
    super.previousAmount,
  });

  factory RevenueItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueItemModel(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      previousAmount: json['previousAmount'] != null ? (json['previousAmount'] as num).toDouble() : null,
    );
  }
}

class RevenueMixItemModel extends RevenueMixItem {
  const RevenueMixItemModel({
    required super.category,
    required super.amount,
    required super.percentage,
  });

  factory RevenueMixItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueMixItemModel(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class BranchPerformanceItemModel extends BranchPerformanceItem {
  const BranchPerformanceItemModel({
    required super.branchName,
    required super.revenueMtd,
    required super.vsPreviousMonth,
    required super.operatingCosts,
    required super.netMargin,
    required super.status,
  });

  factory BranchPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return BranchPerformanceItemModel(
      branchName: json['branchName'] as String,
      revenueMtd: (json['revenueMtd'] as num).toDouble(),
      vsPreviousMonth: (json['vsPreviousMonth'] as num).toDouble(),
      operatingCosts: (json['operatingCosts'] as num).toDouble(),
      netMargin: (json['netMargin'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}

class RevenueReportResponseModel extends RevenueReportResponse {
  const RevenueReportResponseModel({
    required super.grossRevenue,
    super.grossRevenueGrowth = 0.0,
    required super.items,
    super.avgRevenuePerBranch = 0.0,
    super.avgRevenueGrowth = 0.0,
    super.topBranchName = '',
    super.topBranchRevenue = 0.0,
    super.forecastQ4 = 0.0,
    super.revenueMix = const [],
    super.branchPerformance = const [],
  });

  factory RevenueReportResponseModel.fromJson(Map<String, dynamic> json) {
    return RevenueReportResponseModel(
      grossRevenue: (json['grossRevenue'] as num).toDouble(),
      grossRevenueGrowth: (json['grossRevenueGrowth'] as num?)?.toDouble() ?? 0.0,
      avgRevenuePerBranch: (json['avgRevenuePerBranch'] as num?)?.toDouble() ?? 0.0,
      avgRevenueGrowth: (json['avgRevenueGrowth'] as num?)?.toDouble() ?? 0.0,
      topBranchName: json['topBranchName'] as String? ?? '',
      topBranchRevenue: (json['topBranchRevenue'] as num?)?.toDouble() ?? 0.0,
      forecastQ4: (json['forecastQ4'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => RevenueItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revenueMix: (json['revenueMix'] as List<dynamic>?)
              ?.map((e) => RevenueMixItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branchPerformance: (json['branchPerformance'] as List<dynamic>?)
              ?.map((e) => BranchPerformanceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
