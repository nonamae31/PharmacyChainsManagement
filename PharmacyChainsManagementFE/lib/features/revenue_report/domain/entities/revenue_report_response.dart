import 'package:equatable/equatable.dart';

class RevenueItem extends Equatable {
  final String date;
  final double amount;
  final double? previousAmount; // For the trend chart comparing to previous

  const RevenueItem({
    required this.date,
    required this.amount,
    this.previousAmount,
  });

  @override
  List<Object?> get props => [date, amount, previousAmount];
}

class RevenueMixItem extends Equatable {
  final String category;
  final double amount;
  final double percentage;

  const RevenueMixItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, amount, percentage];
}

class BranchPerformanceItem extends Equatable {
  final String branchName;
  final double revenueMtd;
  final double vsPreviousMonth;
  final double operatingCosts;
  final double netMargin;
  final String status;

  const BranchPerformanceItem({
    required this.branchName,
    required this.revenueMtd,
    required this.vsPreviousMonth,
    required this.operatingCosts,
    required this.netMargin,
    required this.status,
  });

  @override
  List<Object?> get props => [
        branchName,
        revenueMtd,
        vsPreviousMonth,
        operatingCosts,
        netMargin,
        status,
      ];
}

class RevenueReportResponse extends Equatable {
  final double grossRevenue;
  final double grossRevenueGrowth; // e.g. 12.5
  final List<RevenueItem> items;
  
  final double avgRevenuePerBranch;
  final double avgRevenueGrowth; // e.g. 4.2
  
  final String topBranchName;
  final double topBranchRevenue;
  
  final double forecastQ4;

  final List<RevenueMixItem> revenueMix;
  final List<BranchPerformanceItem> branchPerformance;

  const RevenueReportResponse({
    required this.grossRevenue,
    this.grossRevenueGrowth = 0.0,
    required this.items,
    this.avgRevenuePerBranch = 0.0,
    this.avgRevenueGrowth = 0.0,
    this.topBranchName = '',
    this.topBranchRevenue = 0.0,
    this.forecastQ4 = 0.0,
    this.revenueMix = const [],
    this.branchPerformance = const [],
  });

  @override
  List<Object?> get props => [
        grossRevenue,
        grossRevenueGrowth,
        items,
        avgRevenuePerBranch,
        avgRevenueGrowth,
        topBranchName,
        topBranchRevenue,
        forecastQ4,
        revenueMix,
        branchPerformance,
      ];
}
