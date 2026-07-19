import 'package:equatable/equatable.dart';

String _apiDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class UpdateStaffPayRateRequestDto extends Equatable {
  final String staffId;
  final double hourlyRate;
  final DateTime effectiveFrom;

  const UpdateStaffPayRateRequestDto({
    required this.staffId,
    required this.hourlyRate,
    required this.effectiveFrom,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'hourlyRate': hourlyRate,
    'effectiveFrom': _apiDate(effectiveFrom),
  };

  @override
  List<Object?> get props => [staffId, hourlyRate, effectiveFrom];
}

class UpsertStaffPayrollRequestDto extends Equatable {
  final String staffId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double bonus;
  final double deduction;
  final String status;
  final String? notes;

  const UpsertStaffPayrollRequestDto({
    required this.staffId,
    required this.periodStart,
    required this.periodEnd,
    required this.bonus,
    required this.deduction,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'periodStart': _apiDate(periodStart),
    'periodEnd': _apiDate(periodEnd),
    'bonus': bonus,
    'deduction': deduction,
    'status': status,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  @override
  List<Object?> get props => [
    staffId,
    periodStart,
    periodEnd,
    bonus,
    deduction,
    status,
    notes,
  ];
}

class StaffPayrollAttendanceDayDto extends Equatable {
  final DateTime attendanceDate;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String? scheduledStartTime;
  final String? scheduledEndTime;
  final int lateMinutes;
  final double payableHours;

  const StaffPayrollAttendanceDayDto({
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.lateMinutes,
    required this.payableHours,
  });

  factory StaffPayrollAttendanceDayDto.fromJson(Map<String, dynamic> json) =>
      StaffPayrollAttendanceDayDto(
        attendanceDate: DateTime.parse(json['attendanceDate'].toString()),
        checkInTime: DateTime.parse(json['checkInTime'].toString()),
        checkOutTime: json['checkOutTime'] == null
            ? null
            : DateTime.parse(json['checkOutTime'].toString()),
        status: json['status']?.toString() ?? '',
        scheduledStartTime: json['scheduledStartTime']?.toString(),
        scheduledEndTime: json['scheduledEndTime']?.toString(),
        lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
        payableHours: (json['payableHours'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'attendanceDate': _apiDate(attendanceDate),
    'checkInTime': checkInTime.toIso8601String(),
    if (checkOutTime != null) 'checkOutTime': checkOutTime!.toIso8601String(),
    'status': status,
    'scheduledStartTime': scheduledStartTime,
    'scheduledEndTime': scheduledEndTime,
    'lateMinutes': lateMinutes,
    'payableHours': payableHours,
  };

  @override
  List<Object?> get props => [
    attendanceDate,
    checkInTime,
    checkOutTime,
    status,
    scheduledStartTime,
    scheduledEndTime,
    lateMinutes,
    payableHours,
  ];
}

class StaffPayrollRowDto extends Equatable {
  final String? payrollId;
  final String staffId;
  final String staffName;
  final double? hourlyRate;
  final double completedHours;
  final int attendanceDays;
  final int periodDays;
  final int lateDays;
  final int lateMinutes;
  final double latePayReduction;
  final List<StaffPayrollAttendanceDayDto> attendanceRecords;
  final double basePay;
  final double bonus;
  final double deduction;
  final double netPay;
  final String status;
  final String? notes;
  final DateTime? updatedAt;

  const StaffPayrollRowDto({
    required this.payrollId,
    required this.staffId,
    required this.staffName,
    required this.hourlyRate,
    required this.completedHours,
    required this.attendanceDays,
    required this.periodDays,
    required this.lateDays,
    required this.lateMinutes,
    required this.latePayReduction,
    required this.attendanceRecords,
    required this.basePay,
    required this.bonus,
    required this.deduction,
    required this.netPay,
    required this.status,
    required this.notes,
    required this.updatedAt,
  });

  factory StaffPayrollRowDto.fromJson(
    Map<String, dynamic> json,
  ) => StaffPayrollRowDto(
    payrollId: json['payrollId']?.toString(),
    staffId: json['staffId'].toString(),
    staffName: json['staffName']?.toString() ?? '',
    hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
    completedHours: (json['completedHours'] as num?)?.toDouble() ?? 0,
    attendanceDays: (json['attendanceDays'] as num?)?.toInt() ?? 0,
    periodDays: (json['periodDays'] as num?)?.toInt() ?? 0,
    lateDays: (json['lateDays'] as num?)?.toInt() ?? 0,
    lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
    latePayReduction: (json['latePayReduction'] as num?)?.toDouble() ?? 0,
    attendanceRecords: (json['attendanceRecords'] as List<dynamic>? ?? const [])
        .map(
          (item) => StaffPayrollAttendanceDayDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false),
    basePay: (json['basePay'] as num?)?.toDouble() ?? 0,
    bonus: (json['bonus'] as num?)?.toDouble() ?? 0,
    deduction: (json['deduction'] as num?)?.toDouble() ?? 0,
    netPay: (json['netPay'] as num?)?.toDouble() ?? 0,
    status: json['status']?.toString() ?? 'NOT_CALCULATED',
    notes: json['notes'] as String?,
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'].toString()),
  );

  bool get isConfirmed => status.toUpperCase() == 'CONFIRMED';

  @override
  List<Object?> get props => [
    payrollId,
    staffId,
    staffName,
    hourlyRate,
    completedHours,
    attendanceDays,
    periodDays,
    lateDays,
    lateMinutes,
    latePayReduction,
    attendanceRecords,
    basePay,
    bonus,
    deduction,
    netPay,
    status,
    notes,
    updatedAt,
  ];
}

class StaffPayrollSummaryDto extends Equatable {
  final String branchId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalCompletedHours;
  final int totalLateMinutes;
  final double totalLatePayReduction;
  final double totalBasePay;
  final double totalBonus;
  final double totalDeduction;
  final double totalNetPay;
  final List<StaffPayrollRowDto> staff;

  const StaffPayrollSummaryDto({
    required this.branchId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalCompletedHours,
    required this.totalLateMinutes,
    required this.totalLatePayReduction,
    required this.totalBasePay,
    required this.totalBonus,
    required this.totalDeduction,
    required this.totalNetPay,
    required this.staff,
  });

  factory StaffPayrollSummaryDto.fromJson(Map<String, dynamic> json) =>
      StaffPayrollSummaryDto(
        branchId: json['branchId'].toString(),
        periodStart: DateTime.parse(json['periodStart'].toString()),
        periodEnd: DateTime.parse(json['periodEnd'].toString()),
        totalCompletedHours:
            (json['totalCompletedHours'] as num?)?.toDouble() ?? 0,
        totalLateMinutes: (json['totalLateMinutes'] as num?)?.toInt() ?? 0,
        totalLatePayReduction:
            (json['totalLatePayReduction'] as num?)?.toDouble() ?? 0,
        totalBasePay: (json['totalBasePay'] as num?)?.toDouble() ?? 0,
        totalBonus: (json['totalBonus'] as num?)?.toDouble() ?? 0,
        totalDeduction: (json['totalDeduction'] as num?)?.toDouble() ?? 0,
        totalNetPay: (json['totalNetPay'] as num?)?.toDouble() ?? 0,
        staff: (json['staff'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  StaffPayrollRowDto.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
      );

  @override
  List<Object?> get props => [
    branchId,
    periodStart,
    periodEnd,
    totalCompletedHours,
    totalLateMinutes,
    totalLatePayReduction,
    totalBasePay,
    totalBonus,
    totalDeduction,
    totalNetPay,
    staff,
  ];
}
