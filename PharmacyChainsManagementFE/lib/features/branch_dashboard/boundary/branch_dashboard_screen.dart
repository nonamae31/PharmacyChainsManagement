import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../../staff_performance/boundary/widgets/staff_management_dialogs.dart';
import '../../staff_performance/control/staff_performance_bloc.dart';
import '../../staff_performance/control/staff_performance_event.dart';
import '../../staff_performance/control/staff_performance_state.dart';
import '../../staff_performance/entity/staff_management_dto.dart';
import '../control/branch_dashboard_bloc.dart';
import '../control/branch_dashboard_event.dart';
import '../control/branch_dashboard_state.dart';
import '../entity/daily_revenue_confirmation_dto.dart';
import 'widgets/branch_dashboard_content.dart';
import 'widgets/daily_revenue_confirmation_dialog.dart';
import 'widgets/daily_revenue_confirmation_details_dialog.dart';

class BranchDashboardScreen extends StatefulWidget {
  const BranchDashboardScreen({super.key});

  @override
  State<BranchDashboardScreen> createState() => _BranchDashboardScreenState();
}

class _BranchDashboardScreenState extends State<BranchDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchDashboardBloc>().add(
      const BranchDashboardFetchRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BranchDashboardBloc, BranchDashboardState>(
      listener: (context, state) {
        if (state is DailyRevenueConfirmationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.confirmationSucceeded)),
          );
        }
      },
      builder: (context, state) {
        final mobile =
            MediaQuery.sizeOf(context).width <
            AppSpacing.mobileHeaderBreakpoint;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(mobile ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              children: [
                AppPageHeader(
                  title: AppStrings.branchManagerDashboard,
                  subtitle: state is BranchDashboardLoadSuccess
                      ? '${AppStrings.dashboardSubtitle} — ${state.dashboard.branchName}'
                      : AppStrings.dashboardSubtitle,
                ),
                SizedBox(height: mobile ? AppSpacing.md : AppSpacing.lg),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BranchDashboardState state) {
    return switch (state) {
      BranchDashboardInitial() ||
      BranchDashboardLoading() => const AppLoadingIndicator(),
      BranchDashboardLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => context.read<BranchDashboardBloc>().add(
          const BranchDashboardFetchRequested(),
        ),
      ),
      BranchDashboardLoadSuccess() => BranchDashboardContent(
        state: state,
        onUpdateRoster: _showShiftRoster,
        onPeriodSelected: (period) => context.read<BranchDashboardBloc>().add(
          BranchDashboardPeriodChanged(period),
        ),
        onFilterAlerts: () => context.read<BranchDashboardBloc>().add(
          const BranchDashboardAlertsFilterToggled(),
        ),
        onConfirmRevenue: () => _showConfirmation(state),
        onViewConfirmation: () =>
            _showConfirmationDetails(state.dashboard.todayRevenueConfirmation!),
      ),
    };
  }

  Future<void> _showConfirmation(BranchDashboardLoadSuccess state) async {
    final request = await showDialog<ConfirmDailyRevenueRequestDto>(
      context: context,
      builder: (_) => DailyRevenueConfirmationDialog(
        systemRevenue: state.dashboard.metrics.todayRevenue,
      ),
    );
    if (request != null && mounted) {
      context.read<BranchDashboardBloc>().add(
        DailyRevenueConfirmationSubmitted(request),
      );
    }
  }

  Future<void> _showConfirmationDetails(
    DailyRevenueConfirmationDto confirmation,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          DailyRevenueConfirmationDetailsDialog(confirmation: confirmation),
    );
  }

  Future<void> _showShiftRoster() async {
    final staffBloc = context.read<StaffPerformanceBloc>();
    StaffPerformanceState staffState = staffBloc.state;
    if (staffState is! StaffPerformanceLoadSuccess) {
      if (staffState is! StaffPerformanceLoading) {
        staffBloc.add(const StaffPerformanceFetchRequested());
      }
      staffState = await staffBloc.stream
          .firstWhere(
            (state) =>
                state is StaffPerformanceLoadSuccess ||
                state is StaffPerformanceLoadFailure,
          )
          .timeout(
            const Duration(seconds: 35),
            onTimeout: () =>
                const StaffPerformanceLoadFailure(AppStrings.requestTimedOut),
          );
      if (!mounted) return;
    }
    if (staffState case StaffPerformanceLoadFailure(:final message)) {
      _showMessage(message);
      return;
    }
    final loadedState = staffState as StaffPerformanceLoadSuccess;
    if (loadedState.performance.staff.isEmpty) {
      _showMessage(AppStrings.noStaffAvailable);
      return;
    }

    final request = await showDialog<UpsertStaffShiftRequestDto>(
      context: context,
      builder: (_) => StaffShiftDialog(staff: loadedState.performance.staff),
    );
    if (request != null && mounted) {
      staffBloc.add(StaffShiftUpsertRequested(request));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
