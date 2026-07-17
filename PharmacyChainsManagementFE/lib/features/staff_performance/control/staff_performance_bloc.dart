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
    on<BranchStaffCreateRequested>(_onCreateStaff);
    on<StaffShiftUpsertRequested>(_onUpsertShift);
    on<StaffAssessmentCreateRequested>(_onCreateAssessment);
    on<StaffStatusUpdateRequested>(_onUpdateStatus);
  }

  Future<void> _onFetchRequested(
    StaffPerformanceFetchRequested event,
    Emitter<StaffPerformanceState> emit,
  ) async {
    emit(const StaffPerformanceLoading());
    try {
      emit(
        StaffPerformanceLoadSuccess(
          await _apiClient.fetchStaffPerformance(
            search: event.search,
            status: event.status,
            sort: event.sort,
          ),
          search: event.search ?? '',
          status: event.status,
          sort: event.sort,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(StaffPerformanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffPerformanceLoadFailure(AppStrings.dataCannotLoad));
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

  Future<void> _runOperation(
    Emitter<StaffPerformanceState> emit,
    Future<void> Function() operation,
    String successMessage,
  ) async {
    final current = state;
    if (current is! StaffPerformanceLoadSuccess) return;
    try {
      emit(
        StaffPerformanceLoadSuccess(
          current.performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
        ),
      );
      await operation();
      final performance = await _apiClient.fetchStaffPerformance(
        search: current.search,
        status: current.status,
        sort: current.sort,
      );
      emit(
        StaffPerformanceOperationSuccess(
          performance,
          search: current.search,
          status: current.status,
          sort: current.sort,
          message: successMessage,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(StaffPerformanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffPerformanceLoadFailure(AppStrings.dataCannotLoad));
    }
  }
}
