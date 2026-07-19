import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/network_exceptions.dart';
import '../entity/attendance_check_in_request_dto.dart';
import '../network/staff_attendance_api_client.dart';
import 'staff_attendance_event.dart';
import 'staff_attendance_state.dart';

class StaffAttendanceBloc
    extends Bloc<StaffAttendanceEvent, StaffAttendanceState> {
  final StaffAttendanceApiClient _apiClient;

  StaffAttendanceBloc({required StaffAttendanceApiClient apiClient})
    : _apiClient = apiClient,
      super(StaffAttendanceInitial()) {
    on<StaffAttendanceFetchRequested>(_fetch);
    on<StaffAttendanceDateSelected>(_selectDate);
    on<StaffAttendanceDetailPresented>(_markDetailPresented);
    on<StaffAttendancePeriodChanged>(_changePeriod);
    on<StaffAttendanceCheckInSubmitted>(_checkIn);
  }

  Future<void> _fetch(
    StaffAttendanceFetchRequested event,
    Emitter<StaffAttendanceState> emit,
  ) async {
    emit(StaffAttendanceLoading());
    try {
      final range = event.mobileView
          ? _weekRange(event.focusedDate)
          : _monthRange(event.focusedDate);
      final records = await _apiClient.fetchAttendance(
        from: range.$1,
        to: range.$2,
      );
      emit(
        StaffAttendanceLoadSuccess(
          focusedDate: event.focusedDate,
          selectedDate: event.focusedDate,
          mobileView: event.mobileView,
          visibleDates: _dates(range.$1, range.$2),
          records: records,
        ),
      );
    } on AppException catch (error) {
      emit(StaffAttendanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffAttendanceLoadFailure(AppStrings.unknownError));
    }
  }

  void _selectDate(
    StaffAttendanceDateSelected event,
    Emitter<StaffAttendanceState> emit,
  ) {
    final current = state;
    if (current is StaffAttendanceLoadSuccess) {
      emit(
        current.copyWith(
          selectedDate: event.date,
          detailRequested: true,
          clearOperationMessage: true,
        ),
      );
    }
  }

  void _markDetailPresented(
    StaffAttendanceDetailPresented event,
    Emitter<StaffAttendanceState> emit,
  ) {
    final current = state;
    if (current is StaffAttendanceLoadSuccess && current.detailRequested) {
      emit(current.copyWith(detailRequested: false));
    }
  }

  void _changePeriod(
    StaffAttendancePeriodChanged event,
    Emitter<StaffAttendanceState> emit,
  ) {
    final current = state;
    if (current is! StaffAttendanceLoadSuccess) return;
    final date = current.mobileView
        ? current.focusedDate.add(Duration(days: 7 * event.offset))
        : DateTime(
            current.focusedDate.year,
            current.focusedDate.month + event.offset,
          );
    add(
      StaffAttendanceFetchRequested(
        focusedDate: date,
        mobileView: current.mobileView,
      ),
    );
  }

  Future<void> _checkIn(
    StaffAttendanceCheckInSubmitted event,
    Emitter<StaffAttendanceState> emit,
  ) async {
    final current = state;
    if (current is! StaffAttendanceLoadSuccess || !current.canCheckIn) return;
    emit(current.copyWith(checkInInProgress: true, clearOperationMessage: true));
    try {
      final record = await _apiClient.checkIn(
        AttendanceCheckInRequestDto(attendanceDate: current.selectedDate),
      );
      emit(
        current.copyWith(
          records: [...current.records, record],
          checkInInProgress: false,
          operationMessage: AppStrings.attendanceCheckInSuccess,
        ),
      );
    } on AppException catch (error) {
      emit(StaffAttendanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffAttendanceLoadFailure(AppStrings.unknownError));
    }
  }

  (DateTime, DateTime) _monthRange(DateTime date) {
    final first = DateTime(date.year, date.month);
    return (first, DateTime(date.year, date.month + 1, 0));
  }

  (DateTime, DateTime) _weekRange(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - DateTime.monday),
    );
    return (start, start.add(const Duration(days: 6)));
  }

  List<DateTime> _dates(DateTime from, DateTime to) => [
    for (
      var date = from;
      !date.isAfter(to);
      date = date.add(const Duration(days: 1))
    )
      date,
  ];
}
