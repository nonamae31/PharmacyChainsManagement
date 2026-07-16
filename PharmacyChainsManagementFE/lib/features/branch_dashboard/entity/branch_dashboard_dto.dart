import 'package:equatable/equatable.dart';

class RevenuePointDto extends Equatable {
  final DateTime date;
  final double revenue;

  const RevenuePointDto({required this.date, required this.revenue});

  factory RevenuePointDto.fromJson(Map<String, dynamic> json) =>
      RevenuePointDto(
        date: DateTime.parse(json['date'].toString()),
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'revenue': revenue,
  };

  @override
  List<Object?> get props => [date, revenue];
}

class DashboardMetricDto extends Equatable {
  final double todayRevenue;
  final double revenueChangePercent;
  final int activeStaff;
  final int totalStaff;
  final int stockAlerts;
  final double branchEfficiencyPercent;

  const DashboardMetricDto({
    required this.todayRevenue,
    required this.revenueChangePercent,
    required this.activeStaff,
    required this.totalStaff,
    required this.stockAlerts,
    required this.branchEfficiencyPercent,
  });

  factory DashboardMetricDto.fromJson(Map<String, dynamic> json) =>
      DashboardMetricDto(
        todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
        revenueChangePercent:
            (json['revenueChangePercent'] as num?)?.toDouble() ?? 0,
        activeStaff: (json['activeStaff'] as num?)?.toInt() ?? 0,
        totalStaff: (json['totalStaff'] as num?)?.toInt() ?? 0,
        stockAlerts: (json['stockAlerts'] as num?)?.toInt() ?? 0,
        branchEfficiencyPercent:
            (json['branchEfficiencyPercent'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'todayRevenue': todayRevenue,
    'revenueChangePercent': revenueChangePercent,
    'activeStaff': activeStaff,
    'totalStaff': totalStaff,
    'stockAlerts': stockAlerts,
    'branchEfficiencyPercent': branchEfficiencyPercent,
  };

  @override
  List<Object?> get props => [
    todayRevenue,
    revenueChangePercent,
    activeStaff,
    totalStaff,
    stockAlerts,
    branchEfficiencyPercent,
  ];
}

class DashboardStaffDto extends Equatable {
  final String staffId;
  final String fullName;
  final String roleName;
  final double salesRevenue;

  const DashboardStaffDto({
    required this.staffId,
    required this.fullName,
    required this.roleName,
    required this.salesRevenue,
  });

  factory DashboardStaffDto.fromJson(Map<String, dynamic> json) =>
      DashboardStaffDto(
        staffId: json['staffId'].toString(),
        fullName: json['fullName']?.toString() ?? '',
        roleName: json['roleName']?.toString() ?? '',
        salesRevenue: (json['salesRevenue'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'fullName': fullName,
    'roleName': roleName,
    'salesRevenue': salesRevenue,
  };

  @override
  List<Object?> get props => [staffId, fullName, roleName, salesRevenue];
}

class DashboardInventoryDto extends Equatable {
  final String medicineId;
  final String sku;
  final String medicineName;
  final String category;
  final int currentStock;
  final int reorderPoint;
  final String status;

  const DashboardInventoryDto({
    required this.medicineId,
    required this.sku,
    required this.medicineName,
    required this.category,
    required this.currentStock,
    required this.reorderPoint,
    required this.status,
  });

  factory DashboardInventoryDto.fromJson(Map<String, dynamic> json) =>
      DashboardInventoryDto(
        medicineId: json['medicineId'].toString(),
        sku: json['sku']?.toString() ?? '',
        medicineName: json['medicineName']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
        reorderPoint: (json['reorderPoint'] as num?)?.toInt() ?? 0,
        status: json['status']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'medicineId': medicineId,
    'sku': sku,
    'medicineName': medicineName,
    'category': category,
    'currentStock': currentStock,
    'reorderPoint': reorderPoint,
    'status': status,
  };

  @override
  List<Object?> get props => [
    medicineId,
    sku,
    medicineName,
    category,
    currentStock,
    reorderPoint,
    status,
  ];
}

class BranchDashboardDto extends Equatable {
  final String branchId;
  final String branchName;
  final DashboardMetricDto metrics;
  final List<RevenuePointDto> revenueTrend;
  final List<DashboardStaffDto> topStaff;
  final List<DashboardInventoryDto> inventoryAlerts;

  const BranchDashboardDto({
    required this.branchId,
    required this.branchName,
    required this.metrics,
    required this.revenueTrend,
    required this.topStaff,
    required this.inventoryAlerts,
  });

  factory BranchDashboardDto.fromJson(
    Map<String, dynamic> json,
  ) => BranchDashboardDto(
    branchId: json['branchId'].toString(),
    branchName: json['branchName']?.toString() ?? '',
    metrics: DashboardMetricDto.fromJson(
      json['metrics'] as Map<String, dynamic>,
    ),
    revenueTrend: (json['revenueTrend'] as List<dynamic>? ?? const [])
        .map((item) => RevenuePointDto.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    topStaff: (json['topStaff'] as List<dynamic>? ?? const [])
        .map((item) => DashboardStaffDto.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    inventoryAlerts: (json['inventoryAlerts'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              DashboardInventoryDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'branchName': branchName,
    'metrics': metrics.toJson(),
    'revenueTrend': revenueTrend.map((item) => item.toJson()).toList(),
    'topStaff': topStaff.map((item) => item.toJson()).toList(),
    'inventoryAlerts': inventoryAlerts.map((item) => item.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    branchId,
    branchName,
    metrics,
    revenueTrend,
    topStaff,
    inventoryAlerts,
  ];
}
