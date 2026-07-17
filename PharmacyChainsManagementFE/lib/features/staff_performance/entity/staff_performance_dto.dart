import 'package:equatable/equatable.dart';

class StaffPerformanceRowDto extends Equatable {
  final String staffId;
  final String fullName;
  final String email;
  final String roleName;
  final String status;
  final double salesRevenue;
  final double? salesTarget;
  final double? targetProgressPercent;
  final double? customerRating;
  final double? attendancePercent;
  final double? performanceScore;

  const StaffPerformanceRowDto({
    required this.staffId,
    required this.fullName,
    required this.email,
    required this.roleName,
    required this.status,
    required this.salesRevenue,
    required this.salesTarget,
    required this.targetProgressPercent,
    required this.customerRating,
    required this.attendancePercent,
    required this.performanceScore,
  });

  factory StaffPerformanceRowDto.fromJson(Map<String, dynamic> json) =>
      StaffPerformanceRowDto(
        staffId: json['staffId'].toString(),
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        roleName: json['roleName']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        salesRevenue: (json['salesRevenue'] as num?)?.toDouble() ?? 0,
        salesTarget: (json['salesTarget'] as num?)?.toDouble(),
        targetProgressPercent: (json['targetProgressPercent'] as num?)
            ?.toDouble(),
        customerRating: (json['customerRating'] as num?)?.toDouble(),
        attendancePercent: (json['attendancePercent'] as num?)?.toDouble(),
        performanceScore: (json['performanceScore'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'fullName': fullName,
    'email': email,
    'roleName': roleName,
    'status': status,
    'salesRevenue': salesRevenue,
    'salesTarget': salesTarget,
    'targetProgressPercent': targetProgressPercent,
    'customerRating': customerRating,
    'attendancePercent': attendancePercent,
    'performanceScore': performanceScore,
  };

  @override
  List<Object?> get props => [
    staffId,
    fullName,
    email,
    roleName,
    status,
    salesRevenue,
    salesTarget,
    targetProgressPercent,
    customerRating,
    attendancePercent,
    performanceScore,
  ];
}

class StaffFeedbackDto extends Equatable {
  final String assessmentId;
  final String staffId;
  final String staffName;
  final DateTime assessmentDate;
  final double performanceScore;
  final String notes;

  const StaffFeedbackDto({
    required this.assessmentId,
    required this.staffId,
    required this.staffName,
    required this.assessmentDate,
    required this.performanceScore,
    required this.notes,
  });

  factory StaffFeedbackDto.fromJson(Map<String, dynamic> json) =>
      StaffFeedbackDto(
        assessmentId: json['assessmentId'].toString(),
        staffId: json['staffId'].toString(),
        staffName: json['staffName']?.toString() ?? '',
        assessmentDate: DateTime.parse(json['assessmentDate'].toString()),
        performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 0,
        notes: json['notes']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
    assessmentId,
    staffId,
    staffName,
    assessmentDate,
    performanceScore,
    notes,
  ];
}

class StaffTrendPointDto extends Equatable {
  final String label;
  final double revenue;

  const StaffTrendPointDto({required this.label, required this.revenue});

  factory StaffTrendPointDto.fromJson(Map<String, dynamic> json) =>
      StaffTrendPointDto(
        label: json['label']?.toString() ?? '',
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {'label': label, 'revenue': revenue};

  @override
  List<Object?> get props => [label, revenue];
}

class StaffPerformanceDto extends Equatable {
  final String branchId;
  final double? averageSalesTargetPercent;
  final double? customerSatisfaction;
  final double? teamAttendancePercent;
  final StaffPerformanceRowDto? topPerformer;
  final List<StaffPerformanceRowDto> staff;
  final List<StaffTrendPointDto> trend;
  final List<StaffFeedbackDto> recentFeedback;

  const StaffPerformanceDto({
    required this.branchId,
    required this.averageSalesTargetPercent,
    required this.customerSatisfaction,
    required this.teamAttendancePercent,
    required this.topPerformer,
    required this.staff,
    required this.trend,
    required this.recentFeedback,
  });

  factory StaffPerformanceDto.fromJson(
    Map<String, dynamic> json,
  ) => StaffPerformanceDto(
    branchId: json['branchId'].toString(),
    averageSalesTargetPercent: (json['averageSalesTargetPercent'] as num?)
        ?.toDouble(),
    customerSatisfaction: (json['customerSatisfaction'] as num?)?.toDouble(),
    teamAttendancePercent: (json['teamAttendancePercent'] as num?)?.toDouble(),
    topPerformer: json['topPerformer'] == null
        ? null
        : StaffPerformanceRowDto.fromJson(
            json['topPerformer'] as Map<String, dynamic>,
          ),
    staff: (json['staff'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              StaffPerformanceRowDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
    trend: (json['trend'] as List<dynamic>? ?? const [])
        .map(
          (item) => StaffTrendPointDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false),
    recentFeedback: (json['recentFeedback'] as List<dynamic>? ?? const [])
        .map((item) => StaffFeedbackDto.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'averageSalesTargetPercent': averageSalesTargetPercent,
    'customerSatisfaction': customerSatisfaction,
    'teamAttendancePercent': teamAttendancePercent,
    'topPerformer': topPerformer?.toJson(),
    'staff': staff.map((item) => item.toJson()).toList(),
    'trend': trend.map((item) => item.toJson()).toList(),
    'recentFeedback': recentFeedback,
  };

  @override
  List<Object?> get props => [
    branchId,
    averageSalesTargetPercent,
    customerSatisfaction,
    teamAttendancePercent,
    topPerformer,
    staff,
    trend,
    recentFeedback,
  ];
}
