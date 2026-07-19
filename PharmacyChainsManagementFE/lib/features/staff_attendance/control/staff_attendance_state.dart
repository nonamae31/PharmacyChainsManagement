import 'package:equatable/equatable.dart';

import '../entity/attendance_record_dto.dart';

sealed class StaffAttendanceState extends Equatable {
  const StaffAttendanceState();

  @override
  List<Object?> get props => [];
}

final class StaffAttendanceInitial extends StaffAttendanceState {}

final class StaffAttendanceLoading extends StaffAttendanceState {}

final class StaffAttendanceLoadSuccess extends StaffAttendanceState {
  final DateTime focusedDate;
  final DateTime selectedDate;
  final bool mobileView;
  final List<DateTime> visibleDates;
  final List<AttendanceRecordDto> records;
  final bool checkInInProgress;
  final bool detailRequested;
  final String? operationMessage;

  const StaffAttendanceLoadSuccess({
    required this.focusedDate,
    required this.selectedDate,
    required this.mobileView,
    required this.visibleDates,
    required this.records,
    this.checkInInProgress = false,
    this.detailRequested = false,
    this.operationMessage,
  });

  AttendanceRecordDto? get selectedRecord {
    for (final record in records) {
      if (_sameDay(record.attendanceDate, selectedDate)) return record;
    }
    return null;
  }

  bool get canCheckIn {
    final now = DateTime.now();
    return _sameDay(selectedDate, now) && selectedRecord == null;
  }

  StaffAttendanceLoadSuccess copyWith({
    DateTime? selectedDate,
    List<AttendanceRecordDto>? records,
    bool? checkInInProgress,
    bool? detailRequested,
    String? operationMessage,
    bool clearOperationMessage = false,
  }) => StaffAttendanceLoadSuccess(
    focusedDate: focusedDate,
    selectedDate: selectedDate ?? this.selectedDate,
    mobileView: mobileView,
    visibleDates: visibleDates,
    records: records ?? this.records,
    checkInInProgress: checkInInProgress ?? this.checkInInProgress,
    detailRequested: detailRequested ?? this.detailRequested,
    operationMessage: clearOperationMessage
        ? null
        : operationMessage ?? this.operationMessage,
  );

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;

  @override
  List<Object?> get props => [
    focusedDate,
    selectedDate,
    mobileView,
    visibleDates,
    records,
    checkInInProgress,
    detailRequested,
    operationMessage,
  ];
}

final class StaffAttendanceLoadFailure extends StaffAttendanceState {
  final String message;

  const StaffAttendanceLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
