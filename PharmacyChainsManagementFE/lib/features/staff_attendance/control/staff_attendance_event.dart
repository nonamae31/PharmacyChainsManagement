import 'package:equatable/equatable.dart';

sealed class StaffAttendanceEvent extends Equatable {
  const StaffAttendanceEvent();

  @override
  List<Object?> get props => [];
}

final class StaffAttendanceFetchRequested extends StaffAttendanceEvent {
  final DateTime focusedDate;
  final bool mobileView;

  const StaffAttendanceFetchRequested({
    required this.focusedDate,
    required this.mobileView,
  });

  @override
  List<Object?> get props => [focusedDate, mobileView];
}

final class StaffAttendanceDateSelected extends StaffAttendanceEvent {
  final DateTime date;

  const StaffAttendanceDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

final class StaffAttendanceDetailPresented extends StaffAttendanceEvent {
  const StaffAttendanceDetailPresented();
}

final class StaffAttendancePeriodChanged extends StaffAttendanceEvent {
  final int offset;

  const StaffAttendancePeriodChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

final class StaffAttendanceCheckInSubmitted extends StaffAttendanceEvent {
  const StaffAttendanceCheckInSubmitted();
}
