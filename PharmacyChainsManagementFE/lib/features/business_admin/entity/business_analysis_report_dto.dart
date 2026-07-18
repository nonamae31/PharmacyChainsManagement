import 'package:equatable/equatable.dart';

class BusinessAnalysisFilterDto extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final String? branchSearch;
  final String viewMode;

  const BusinessAnalysisFilterDto({
    required this.fromDate,
    required this.toDate,
    this.branchSearch,
    this.viewMode = 'summary',
  });

  Map<String, dynamic> toQueryParameters() => {
    'fromDate': _dateOnly(fromDate),
    'toDate': _dateOnly(toDate),
    'branchSearch': branchSearch,
    'viewMode': viewMode,
  }..removeWhere((_, value) => value == null || value == '');

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  List<Object?> get props => [fromDate, toDate, branchSearch, viewMode];
}

class BusinessAnalysisReportDto extends Equatable {
  final String? reportId;
  final DateTime generatedAt;
  final BusinessAnalysisSummaryDto summary;
  final List<RevenueTrendDto> revenueTrend;
  final List<CategorySalesDto> salesByCategory;
  final List<BranchFinancialSummaryDto> branchFinancialSummary;

  const BusinessAnalysisReportDto({
    required this.generatedAt,
    required this.summary,
    required this.revenueTrend,
    required this.salesByCategory,
    required this.branchFinancialSummary,
    this.reportId,
  });

  factory BusinessAnalysisReportDto.fromJson(Map<String, dynamic> json) =>
      BusinessAnalysisReportDto(
        reportId: json['reportId']?.toString(),
        generatedAt:
            DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        summary: BusinessAnalysisSummaryDto.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {},
        ),
        revenueTrend: (json['revenueTrend'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(RevenueTrendDto.fromJson)
            .toList(),
        salesByCategory: (json['salesByCategory'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CategorySalesDto.fromJson)
            .toList(),
        branchFinancialSummary: (json['branchFinancialSummary'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(BranchFinancialSummaryDto.fromJson)
            .toList(),
      );

  @override
  List<Object?> get props => [
    reportId,
    generatedAt,
    summary,
    revenueTrend,
    salesByCategory,
    branchFinancialSummary,
  ];
}

class BusinessAnalysisSummaryDto extends Equatable {
  final double totalRevenue;
  final double? netProfitMargin;
  final double? customerGrowth;
  final double? averageBasketSize;
  final int completedTransactionCount;

  const BusinessAnalysisSummaryDto({
    required this.totalRevenue,
    required this.completedTransactionCount,
    this.netProfitMargin,
    this.customerGrowth,
    this.averageBasketSize,
  });

  factory BusinessAnalysisSummaryDto.fromJson(Map<String, dynamic> json) =>
      BusinessAnalysisSummaryDto(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
        netProfitMargin: (json['netProfitMargin'] as num?)?.toDouble(),
        customerGrowth: (json['customerGrowth'] as num?)?.toDouble(),
        averageBasketSize: (json['averageBasketSize'] as num?)?.toDouble(),
        completedTransactionCount:
            json['completedTransactionCount'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [
    totalRevenue,
    netProfitMargin,
    customerGrowth,
    averageBasketSize,
    completedTransactionCount,
  ];
}

class RevenueTrendDto extends Equatable {
  final String period;
  final double revenue;

  const RevenueTrendDto({required this.period, required this.revenue});

  factory RevenueTrendDto.fromJson(Map<String, dynamic> json) =>
      RevenueTrendDto(
        period: json['period']?.toString() ?? '',
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [period, revenue];
}

class CategorySalesDto extends Equatable {
  final String category;
  final double revenue;

  const CategorySalesDto({required this.category, required this.revenue});

  factory CategorySalesDto.fromJson(Map<String, dynamic> json) =>
      CategorySalesDto(
        category: json['category']?.toString() ?? '',
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [category, revenue];
}

class BranchFinancialSummaryDto extends Equatable {
  final String branchId;
  final String branchName;
  final double revenue;
  final String status;

  const BranchFinancialSummaryDto({
    required this.branchId,
    required this.branchName,
    required this.revenue,
    required this.status,
  });

  factory BranchFinancialSummaryDto.fromJson(Map<String, dynamic> json) =>
      BranchFinancialSummaryDto(
        branchId: json['branchId'].toString(),
        branchName: json['branchName']?.toString() ?? '',
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [branchId, branchName, revenue, status];
}
