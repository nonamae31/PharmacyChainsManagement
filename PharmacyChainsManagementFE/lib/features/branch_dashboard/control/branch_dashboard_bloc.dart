import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../entity/branch_dashboard_dto.dart';
import '../network/branch_dashboard_api_client.dart';
import 'branch_dashboard_event.dart';
import 'branch_dashboard_state.dart';

class BranchDashboardBloc
    extends Bloc<BranchDashboardEvent, BranchDashboardState> {
  final BranchDashboardApiClient _apiClient;

  BranchDashboardBloc(this._apiClient) : super(const BranchDashboardInitial()) {
    on<BranchDashboardFetchRequested>(_onFetchRequested);
    on<BranchDashboardPeriodChanged>(_onPeriodChanged);
    on<BranchDashboardSearchChanged>(_onSearchChanged);
    on<BranchDashboardAlertsFilterToggled>(_onAlertsFilterToggled);
    on<DailyRevenueConfirmationSubmitted>(_onConfirmationSubmitted);
  }

  Future<void> _onFetchRequested(
    BranchDashboardFetchRequested event,
    Emitter<BranchDashboardState> emit,
  ) async {
    emit(const BranchDashboardLoading());
    try {
      final dashboard = await _apiClient.fetchDashboard(
        trendPeriod: event.trendPeriod,
      );
      emit(
        BranchDashboardLoadSuccess(
          dashboard: dashboard,
          trendPeriod: event.trendPeriod,
          visibleStaff: dashboard.topStaff,
          visibleInventory: dashboard.inventoryAlerts,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(BranchDashboardLoadFailure(error.message));
    } catch (_) {
      emit(const BranchDashboardLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  void _onSearchChanged(
    BranchDashboardSearchChanged event,
    Emitter<BranchDashboardState> emit,
  ) {
    final current = state;
    if (current is! BranchDashboardLoadSuccess) return;
    final query = event.query.trim().toLowerCase();
    emit(
      BranchDashboardLoadSuccess(
        dashboard: current.dashboard,
        searchQuery: event.query,
        trendPeriod: current.trendPeriod,
        criticalAlertsOnly: current.criticalAlertsOnly,
        visibleStaff: current.dashboard.topStaff
            .where(
              (item) =>
                  item.fullName.toLowerCase().contains(query) ||
                  item.roleName.toLowerCase().contains(query),
            )
            .toList(growable: false),
        visibleInventory: _filterInventory(
          current.dashboard.inventoryAlerts,
          event.query,
          current.criticalAlertsOnly,
        ),
      ),
    );
  }

  void _onAlertsFilterToggled(
    BranchDashboardAlertsFilterToggled event,
    Emitter<BranchDashboardState> emit,
  ) {
    final current = state;
    if (current is! BranchDashboardLoadSuccess) return;
    final criticalAlertsOnly = !current.criticalAlertsOnly;
    emit(
      BranchDashboardLoadSuccess(
        dashboard: current.dashboard,
        searchQuery: current.searchQuery,
        trendPeriod: current.trendPeriod,
        criticalAlertsOnly: criticalAlertsOnly,
        visibleStaff: current.visibleStaff,
        visibleInventory: _filterInventory(
          current.dashboard.inventoryAlerts,
          current.searchQuery,
          criticalAlertsOnly,
        ),
      ),
    );
  }

  void _onPeriodChanged(
    BranchDashboardPeriodChanged event,
    Emitter<BranchDashboardState> emit,
  ) {
    add(BranchDashboardFetchRequested(trendPeriod: event.trendPeriod));
  }

  Future<void> _onConfirmationSubmitted(
    DailyRevenueConfirmationSubmitted event,
    Emitter<BranchDashboardState> emit,
  ) async {
    final current = state;
    if (current is! BranchDashboardLoadSuccess) return;
    try {
      final confirmation = await _apiClient.confirmDailyRevenue(event.request);
      final dashboard = await _apiClient.fetchDashboard(
        trendPeriod: current.trendPeriod,
      );
      emit(
        DailyRevenueConfirmationSuccess(
          dashboard: dashboard,
          searchQuery: current.searchQuery,
          trendPeriod: current.trendPeriod,
          criticalAlertsOnly: current.criticalAlertsOnly,
          visibleStaff: _filterStaff(dashboard.topStaff, current.searchQuery),
          visibleInventory: _filterInventory(
            dashboard.inventoryAlerts,
            current.searchQuery,
            current.criticalAlertsOnly,
          ),
          confirmation: confirmation,
        ),
      );
    } on BranchManagerAppException catch (error) {
      emit(BranchDashboardLoadFailure(error.message));
    } catch (_) {
      emit(const BranchDashboardLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  List<DashboardInventoryDto> _filterInventory(
    List<DashboardInventoryDto> inventory,
    String searchQuery,
    bool criticalAlertsOnly,
  ) {
    final query = searchQuery.trim().toLowerCase();
    return inventory
        .where(
          (item) =>
              (!criticalAlertsOnly ||
                  item.status.toLowerCase() ==
                      AppStrings.critical.toLowerCase()) &&
              (item.medicineName.toLowerCase().contains(query) ||
                  item.sku.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query) ||
                  item.status.toLowerCase().contains(query)),
        )
        .toList(growable: false);
  }

  List<DashboardStaffDto> _filterStaff(
    List<DashboardStaffDto> staff,
    String searchQuery,
  ) {
    final query = searchQuery.trim().toLowerCase();
    return staff
        .where(
          (item) =>
              item.fullName.toLowerCase().contains(query) ||
              item.roleName.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }
}
