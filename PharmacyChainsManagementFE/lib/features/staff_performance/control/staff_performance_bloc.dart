import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../network/staff_performance_api_client.dart';
import 'staff_performance_event.dart';
import 'staff_performance_state.dart';

class StaffPerformanceBloc extends Bloc<StaffPerformanceEvent, StaffPerformanceState> {
  final StaffPerformanceApiClient _apiClient;

  StaffPerformanceBloc(this._apiClient) : super(const StaffPerformanceInitial()) {
    on<StaffPerformanceFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(StaffPerformanceFetchRequested event, Emitter<StaffPerformanceState> emit) async {
    emit(const StaffPerformanceLoading());
    try {
      emit(StaffPerformanceLoadSuccess(await _apiClient.fetchStaffPerformance(search: event.search)));
    } on BranchManagerAppException catch (error) {
      emit(StaffPerformanceLoadFailure(error.message));
    } catch (_) {
      emit(const StaffPerformanceLoadFailure(AppStrings.dataCannotLoad));
    }
  }
}
