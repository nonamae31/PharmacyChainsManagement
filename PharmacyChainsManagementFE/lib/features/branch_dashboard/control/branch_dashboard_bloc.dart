import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../network/branch_dashboard_api_client.dart';
import 'branch_dashboard_event.dart';
import 'branch_dashboard_state.dart';

class BranchDashboardBloc extends Bloc<BranchDashboardEvent, BranchDashboardState> {
  final BranchDashboardApiClient _apiClient;

  BranchDashboardBloc(this._apiClient) : super(const BranchDashboardInitial()) {
    on<BranchDashboardFetchRequested>(_onFetchRequested);
    on<BranchDashboardSearchChanged>(_onSearchChanged);
    on<DailyRevenueConfirmationSubmitted>(_onConfirmationSubmitted);
  }

  Future<void> _onFetchRequested(
    BranchDashboardFetchRequested event,
    Emitter<BranchDashboardState> emit,
  ) async {
    emit(const BranchDashboardLoading());
    try {
      final dashboard = await _apiClient.fetchDashboard();
      emit(BranchDashboardLoadSuccess(
        dashboard: dashboard,
        visibleStaff: dashboard.topStaff,
        visibleInventory: dashboard.inventoryAlerts,
      ));
    } on BranchManagerAppException catch (error) {
      emit(BranchDashboardLoadFailure(error.message));
    } catch (_) {
      emit(const BranchDashboardLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  void _onSearchChanged(BranchDashboardSearchChanged event, Emitter<BranchDashboardState> emit) {
    final current = state;
    if (current is! BranchDashboardLoadSuccess) return;
    final query = event.query.trim().toLowerCase();
    emit(BranchDashboardLoadSuccess(
      dashboard: current.dashboard,
      searchQuery: event.query,
      visibleStaff: current.dashboard.topStaff
          .where((item) => item.fullName.toLowerCase().contains(query) || item.roleName.toLowerCase().contains(query))
          .toList(growable: false),
      visibleInventory: current.dashboard.inventoryAlerts
          .where((item) => item.medicineName.toLowerCase().contains(query) || item.sku.toLowerCase().contains(query))
          .toList(growable: false),
    ));
  }

  Future<void> _onConfirmationSubmitted(
    DailyRevenueConfirmationSubmitted event,
    Emitter<BranchDashboardState> emit,
  ) async {
    final current = state;
    if (current is! BranchDashboardLoadSuccess) return;
    try {
      final confirmation = await _apiClient.confirmDailyRevenue(event.request);
      emit(DailyRevenueConfirmationSuccess(
        dashboard: current.dashboard,
        searchQuery: current.searchQuery,
        visibleStaff: current.visibleStaff,
        visibleInventory: current.visibleInventory,
        confirmation: confirmation,
      ));
    } on BranchManagerAppException catch (error) {
      emit(BranchDashboardLoadFailure(error.message));
    } catch (_) {
      emit(const BranchDashboardLoadFailure(AppStrings.dataCannotLoad));
    }
  }
}
