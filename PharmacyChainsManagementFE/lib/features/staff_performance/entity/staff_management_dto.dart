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

class UpsertStaffShiftRequestDto extends Equatable {
  final String staffId;
  final DateTime shiftDate;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final String status;
  final String? notes;

  const UpsertStaffShiftRequestDto({
    required this.staffId,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'shiftDate': _date(shiftDate),
    'startTime': startTime.asApiValue,
    'endTime': endTime.asApiValue,
    'status': status,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
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
  ];
}

class TimeOfDayValue extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDayValue(this.hour, this.minute);

  String get asApiValue =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

  @override
  List<Object?> get props => [hour, minute];
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
