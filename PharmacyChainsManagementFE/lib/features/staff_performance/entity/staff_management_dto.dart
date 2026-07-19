import 'package:equatable/equatable.dart';

class CreateBranchStaffRequestDto extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String? phone;

  const CreateBranchStaffRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };

  @override
  List<Object?> get props => [fullName, email, password, phone];
}

class UpdateStaffStatusRequestDto extends Equatable {
  final String staffId;
  final String status;

  const UpdateStaffStatusRequestDto({
    required this.staffId,
    required this.status,
  });

  Map<String, dynamic> toJson() => {'status': status};

  @override
  List<Object?> get props => [staffId, status];
}

class UpsertStaffShiftRequestDto extends Equatable {
  final String staffId;
  final DateTime shiftDate;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final String status;
  final String? notes;
  final bool applyToWeeklySchedule;

  const UpsertStaffShiftRequestDto({
    required this.staffId,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.applyToWeeklySchedule = false,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'shiftDate': _date(shiftDate),
    'startTime': startTime.asApiValue,
    'endTime': endTime.asApiValue,
    'status': status,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'applyToWeeklySchedule': applyToWeeklySchedule,
  };

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    staffId,
    shiftDate,
    startTime,
    endTime,
    status,
    notes,
    applyToWeeklySchedule,
  ];
}

class TimeOfDayValue extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDayValue(this.hour, this.minute);

  factory TimeOfDayValue.fromApiValue(String value) {
    final parts = value.split(':');
    return TimeOfDayValue(int.parse(parts[0]), int.parse(parts[1]));
  }

  String get asApiValue =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

  @override
  List<Object?> get props => [hour, minute];
}

class StaffShiftDto extends Equatable {
  final String shiftId;
  final String staffId;
  final String staffName;
  final DateTime shiftDate;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final String status;
  final String? notes;
  final DateTime updatedAt;
  final bool isRecurring;

  const StaffShiftDto({
    required this.shiftId,
    required this.staffId,
    required this.staffName,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.notes,
    required this.updatedAt,
    required this.isRecurring,
  });

  factory StaffShiftDto.fromJson(Map<String, dynamic> json) => StaffShiftDto(
    shiftId: json['shiftId'].toString(),
    staffId: json['staffId'].toString(),
    staffName: json['staffName'].toString(),
    shiftDate: DateTime.parse(json['shiftDate'].toString()),
    startTime: TimeOfDayValue.fromApiValue(json['startTime'].toString()),
    endTime: TimeOfDayValue.fromApiValue(json['endTime'].toString()),
    status: json['status'].toString(),
    notes: json['notes'] as String?,
    updatedAt: DateTime.parse(json['updatedAt'].toString()),
    isRecurring: json['isRecurring'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'shiftId': shiftId,
    'staffId': staffId,
    'staffName': staffName,
    'shiftDate': UpsertStaffShiftRequestDto._date(shiftDate),
    'startTime': startTime.asApiValue,
    'endTime': endTime.asApiValue,
    'status': status,
    'notes': notes,
    'updatedAt': updatedAt.toIso8601String(),
    'isRecurring': isRecurring,
  };

  @override
  List<Object?> get props => [
    shiftId,
    staffId,
    staffName,
    shiftDate,
    startTime,
    endTime,
    status,
    notes,
    updatedAt,
    isRecurring,
  ];
}

class CreateStaffAssessmentRequestDto extends Equatable {
  final String staffId;
  final DateTime assessmentDate;
  final double salesTarget;
  final double customerRating;
  final double attendancePercent;
  final double performanceScore;
  final String? notes;

  const CreateStaffAssessmentRequestDto({
    required this.staffId,
    required this.assessmentDate,
    required this.salesTarget,
    required this.customerRating,
    required this.attendancePercent,
    required this.performanceScore,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'assessmentDate': UpsertStaffShiftRequestDto._date(assessmentDate),
    'salesTarget': salesTarget,
    'customerRating': customerRating,
    'attendancePercent': attendancePercent,
    'performanceScore': performanceScore,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  @override
  List<Object?> get props => [
    staffId,
    assessmentDate,
    salesTarget,
    customerRating,
    attendancePercent,
    performanceScore,
    notes,
  ];
}
