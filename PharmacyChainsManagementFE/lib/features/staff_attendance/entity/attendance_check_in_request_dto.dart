import 'package:equatable/equatable.dart';

class AttendanceCheckInRequestDto extends Equatable {
  final DateTime attendanceDate;

  const AttendanceCheckInRequestDto({required this.attendanceDate});

  Map<String, dynamic> toJson() => {
    'attendanceDate':
        '${attendanceDate.year.toString().padLeft(4, '0')}-'
        '${attendanceDate.month.toString().padLeft(2, '0')}-'
        '${attendanceDate.day.toString().padLeft(2, '0')}',
  };

  @override
  List<Object?> get props => [attendanceDate];
}
