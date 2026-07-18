import 'package:equatable/equatable.dart';

import '../../branch_dashboard/entity/branch_dashboard_dto.dart';

class CategoryRevenueDto extends Equatable {
  final String category;
  final double revenue;
  final double contributionPercent;

  const CategoryRevenueDto({
    required this.category,
    required this.revenue,
    required this.contributionPercent,
  });

  factory CategoryRevenueDto.fromJson(Map<String, dynamic> json) =>
      CategoryRevenueDto(
        category: json['category']?.toString() ?? '',
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
        contributionPercent:
            (json['contributionPercent'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'category': category,
    'revenue': revenue,
    'contributionPercent': contributionPercent,
  };

  @override
  List<Object?> get props => [category, revenue, contributionPercent];
}

class TimeBlockPerformanceDto extends Equatable {
  final String timeBlock;
  final int transactions;
  final double revenue;
  final double averageOrder;
  final String status;

  const TimeBlockPerformanceDto({
    required this.timeBlock,
    required this.transactions,
    required this.revenue,
    required this.averageOrder,
    required this.status,
  });

  factory TimeBlockPerformanceDto.fromJson(Map<String, dynamic> json) =>
      TimeBlockPerformanceDto(
        timeBlock: json['timeBlock']?.toString() ?? '',
        transactions: (json['transactions'] as num?)?.toInt() ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
        averageOrder: (json['averageOrder'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'timeBlock': timeBlock,
    'transactions': transactions,
    'revenue': revenue,
    'averageOrder': averageOrder,
    'status': status,
  };

  @override
  List<Object?> get props => [
    timeBlock,
    transactions,
    revenue,
    averageOrder,
    status,
  ];
}

class PaymentMethodRevenueDto extends Equatable {
  final String paymentMethod;
  final int transactions;
  final double revenue;
  final double contributionPercent;

  const PaymentMethodRevenueDto({
    required this.paymentMethod,
    required this.transactions,
    required this.revenue,
    required this.contributionPercent,
  });

  factory PaymentMethodRevenueDto.fromJson(Map<String, dynamic> json) =>
      PaymentMethodRevenueDto(
        paymentMethod: json['paymentMethod']?.toString() ?? '',
        transactions: (json['transactions'] as num?)?.toInt() ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
        contributionPercent:
            (json['contributionPercent'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'paymentMethod': paymentMethod,
    'transactions': transactions,
    'revenue': revenue,
    'contributionPercent': contributionPercent,
  };

  @override
  List<Object?> get props => [
    paymentMethod,
    transactions,
    revenue,
    contributionPercent,
  ];
}

class BranchRevenueDto extends Equatable {
  final String branchId;
  final DateTime fromDate;
  final DateTime toDate;
  final double totalRevenue;
  final int totalInvoices;
  final double? grossMarginPercent;
  final List<RevenuePointDto> revenueTrend;
  final List<CategoryRevenueDto> categoryRevenue;
  final List<TimeBlockPerformanceDto> performanceByTime;
  final List<PaymentMethodRevenueDto> paymentMethods;

  const BranchRevenueDto({
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.totalRevenue,
    required this.totalInvoices,
    required this.grossMarginPercent,
    required this.revenueTrend,
    required this.categoryRevenue,
    required this.performanceByTime,
    required this.paymentMethods,
  });

  factory BranchRevenueDto.fromJson(
    Map<String, dynamic> json,
  ) => BranchRevenueDto(
    branchId: json['branchId'].toString(),
    fromDate: DateTime.parse(json['fromDate'].toString()),
    toDate: DateTime.parse(json['toDate'].toString()),
    totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
    grossMarginPercent: (json['grossMarginPercent'] as num?)?.toDouble(),
    revenueTrend: (json['revenueTrend'] as List<dynamic>? ?? const [])
        .map((item) => RevenuePointDto.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    categoryRevenue: (json['categoryRevenue'] as List<dynamic>? ?? const [])
        .map(
          (item) => CategoryRevenueDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
    performanceByTime: (json['performanceByTime'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              TimeBlockPerformanceDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
    paymentMethods: (json['paymentMethods'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              PaymentMethodRevenueDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'fromDate': fromDate.toIso8601String(),
    'toDate': toDate.toIso8601String(),
    'totalRevenue': totalRevenue,
    'totalInvoices': totalInvoices,
    'grossMarginPercent': grossMarginPercent,
    'revenueTrend': revenueTrend.map((item) => item.toJson()).toList(),
    'categoryRevenue': categoryRevenue.map((item) => item.toJson()).toList(),
    'performanceByTime': performanceByTime
        .map((item) => item.toJson())
        .toList(),
    'paymentMethods': paymentMethods.map((item) => item.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    branchId,
    fromDate,
    toDate,
    totalRevenue,
    totalInvoices,
    grossMarginPercent,
    revenueTrend,
    categoryRevenue,
    performanceByTime,
    paymentMethods,
  ];
}
