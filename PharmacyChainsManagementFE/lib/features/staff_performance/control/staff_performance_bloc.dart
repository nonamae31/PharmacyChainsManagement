import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../network/staff_performance_api_client.dart';
import 'staff_performance_event.dart';
import 'staff_performance_state.dart';

class StaffPerformanceBloc
    extends Bloc<StaffPerformanceEvent, StaffPerformanceState> {
  final StaffPerformanceApiClient _apiClient;

  StaffPerformanceBloc(this._apiClient)
    : super(const StaffPerformanceInitial()) {
    on<StaffPerformanceFetchRequested>(_onFetchRequested);
    on<StaffShiftDateSelected>(_onShiftDateSelected);
    on<BranchStaffCreateRequested>(_onCreateStaff);
    on<StaffShiftUpsertRequested>(_onUpsertShift);
    on<StaffAssessmentCreateRequested>(_onCreateAssessment);
    on<StaffStatusUpdateRequested>(_onUpdateStatus);
    on<StaffPayrollPeriodSelected>(_onPayrollPeriodSelected);
    on<StaffPayRateUpsertRequested>(_onUpsertPayRate);
    on<StaffPayrollUpsertRequested>(_onUpsertPayroll);
  }

  Future<void> _onFetchRequested(
    StaffPerformanceFetchRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    emit(const StaffPerformanceLoading());
    try {
      final shiftDate = _startOfWeek(event.shiftDate ?? DateTime.now());
      final performance = await _apiClient.fetchStaffPerformance(
        search: event.search,
        status: event.status,
        sort: event.sort,
      );
      final shifts = await _apiClient.fetchStaffShifts(
        shiftDate,
        shiftDate.add(const Duration(days: 6)),
      );
      final now = _dateOnly(DateTime.now());
      final payroll = await _apiClient.fetchStaffPayroll(
        DateTime(now.year, now.month),
        now,
      );
      emit(
        StaffPerformanceLoadSuccess(
          performance,
          search: event.search ?? '',
          status: event.status,
          sort: event.sort,
          shifts: shifts,
          shiftDate: shiftDate,
          payroll: payroll,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(StaffPerformanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffPerformanceLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  Future<void> _onShiftDateSelected(
    StaffShiftDateSelected event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    final current = state;
    if (current is! StaffPerformanceLoadSuccess) return;
    try {
      final shiftDate = _startOfWeek(event.date);
      final shifts = await _apiClient.fetchStaffShifts(
        shiftDate,
        shiftDate.add(const Duration(days: 6)),
      );
      emit(
        StaffPerformanceLoadSuccess(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: shifts,
          shiftDate: shiftDate,
          payroll: current.payroll,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(
        StaffPerformanceOperationFailure(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: current.payroll,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        StaffPerformanceOperationFailure(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: current.payroll,
          message: AppStrings.dataCannotLoad,
        ),
      );
    }
  }

  Future<void> _onCreateStaff(
    BranchStaffCreateRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.createStaff(event.request),
      AppStrings.staffCreated,
    );
  }

  Future<void> _onUpsertShift(
    StaffShiftUpsertRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.upsertShift(event.request),
      AppStrings.shiftSaved,
      shiftDate: event.request.shiftDate,
    );
  }

  Future<void> _onCreateAssessment(
    StaffAssessmentCreateRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.createAssessment(event.request),
      AppStrings.assessmentSaved,
    );
  }

  Future<void> _onUpdateStatus(
    StaffStatusUpdateRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.updateStaffStatus(event.request),
      event.request.status == 'ACTIVE'
          ? AppStrings.staffActivated
          : AppStrings.staffDeactivated,
    );
  }

  Future<void> _onPayrollPeriodSelected(
    StaffPayrollPeriodSelected event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    final current = state;
    if (current is! StaffPerformanceLoadSuccess) return;
    try {
      final payroll = await _apiClient.fetchStaffPayroll(
        _dateOnly(event.fromDate),
        _dateOnly(event.toDate),
      );
      emit(
        StaffPerformanceLoadSuccess(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: payroll,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(_operationFailure(current, error.message));
    } catch (_) {
      emit(_operationFailure(current, AppStrings.dataCannotLoad));
    }
  }

  Future<void> _onUpsertPayRate(
    StaffPayRateUpsertRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.updateStaffPayRate(event.request),
      AppStrings.payRateSaved,
    );
  }

  Future<void> _onUpsertPayroll(
    StaffPayrollUpsertRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    await _runOperation(
      emit,
      () => _apiClient.upsertStaffPayroll(event.request),
      event.request.status == 'CONFIRMED'
          ? AppStrings.payrollConfirmed
          : AppStrings.payrollSaved,
    );
  }

  Future<void> _runOperation(
    Emitter<StaffPerformanceState> emit,
    Future<void> Function() operation,
    String successMessage, {
    DateTime? shiftDate,
  }) async {
    final current = state;
    if (current is! StaffPerformanceLoadSuccess) return;
    try {
      emit(
        StaffPerformanceLoadSuccess(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: current.payroll,
        ),
      );
      await operation();
      final effectiveShiftDate = _startOfWeek(
        shiftDate ?? current.shiftDate,
      );
      final performance = await _apiClient.fetchStaffPerformance(
        search: current.search,
        status: current.status,
        sort: current.sort,
      );
      final shifts = await _apiClient.fetchStaffShifts(
        effectiveShiftDate,
        effectiveShiftDate.add(const Duration(days: 6)),
      );
      final payroll = await _apiClient.fetchStaffPayroll(
        current.payroll.periodStart,
        current.payroll.periodEnd,
      );
      emit(
        StaffPerformanceOperationSuccess(
          performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: shifts,
          shiftDate: effectiveShiftDate,
          payroll: payroll,
          message: successMessage,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(
        StaffPerformanceOperationFailure(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: current.payroll,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        StaffPerformanceOperationFailure(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          shifts: current.shifts,
          shiftDate: current.shiftDate,
          payroll: current.payroll,
          message: AppStrings.dataCannotLoad,
        ),
      );
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _startOfWeek(DateTime value) {
    final date = _dateOnly(value);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  StaffPerformanceOperationFailure _operationFailure(
    StaffPerformanceLoadSuccess current,
    String message,
  ) => StaffPerformanceOperationFailure(
    current.performance,
    search: current.search,
    status: current.status,
    sort: current.sort,
    shifts: current.shifts,
    shiftDate: current.shiftDate,
    payroll: current.payroll,
    message: message,
  );
}
