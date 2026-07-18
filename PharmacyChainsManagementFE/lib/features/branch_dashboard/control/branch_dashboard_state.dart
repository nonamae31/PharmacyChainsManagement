import 'package:equatable/equatable.dart';

import '../entity/branch_dashboard_dto.dart';
import '../entity/daily_revenue_confirmation_dto.dart';

sealed class BranchDashboardState extends Equatable {
  const BranchDashboardState();

  @override
  List<Object?> get props => [];
}

final class BranchDashboardInitial extends BranchDashboardState {
  const BranchDashboardInitial();
}

final class BranchDashboardLoading extends BranchDashboardState {
  const BranchDashboardLoading();
}

class BranchDashboardLoadSuccess extends BranchDashboardState {
  final BranchDashboardDto dashboard;
  final String searchQuery;
  final String trendPeriod;
  final bool criticalAlertsOnly;
  final List<DashboardStaffDto> visibleStaff;
  final List<DashboardInventoryDto> visibleInventory;

  const BranchDashboardLoadSuccess({
    required this.dashboard,
    this.searchQuery = '',
    this.trendPeriod = 'month',
    this.criticalAlertsOnly = false,
    required this.visibleStaff,
    required this.visibleInventory,
  });

  @override
  List<Object?> get props => [
    dashboard,
    searchQuery,
    trendPeriod,
    criticalAlertsOnly,
    visibleStaff,
    visibleInventory,
  ];
}

final class DailyRevenueConfirmationSuccess extends BranchDashboardLoadSuccess {
  final DailyRevenueConfirmationDto confirmation;

  const DailyRevenueConfirmationSuccess({
    required super.dashboard,
    required super.searchQuery,
    required super.trendPeriod,
    required super.criticalAlertsOnly,
    required super.visibleStaff,
    required super.visibleInventory,
    required this.confirmation,
  });

  @override
  List<Object?> get props => [...super.props, confirmation];
}

final class BranchDashboardLoadFailure extends BranchDashboardState {
  final String message;

  const BranchDashboardLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
