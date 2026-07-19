import 'package:equatable/equatable.dart';

class AttendanceRecordDto extends Equatable {
  final String id;
  final DateTime attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;

  const AttendanceRecordDto({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
  });

  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) =>
      AttendanceRecordDto(
        id: json['id'] as String,
        attendanceDate: DateTime.parse(json['attendanceDate'] as String),
        checkInTime: json['checkInTime'] == null
            ? null
            : DateTime.parse(json['checkInTime'] as String),
        checkOutTime: json['checkOutTime'] == null
            ? null
            : DateTime.parse(json['checkOutTime'] as String),
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'attendanceDate': attendanceDate.toIso8601String(),
    'checkInTime': checkInTime?.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'status': status,
  };

  @override
  List<Object?> get props => [
    id,
    attendanceDate,
    checkInTime,
    checkOutTime,
    status,
  ];
}
