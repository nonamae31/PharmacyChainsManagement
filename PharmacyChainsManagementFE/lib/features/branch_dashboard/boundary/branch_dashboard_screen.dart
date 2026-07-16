import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../control/branch_dashboard_bloc.dart';
import '../control/branch_dashboard_event.dart';
import '../control/branch_dashboard_state.dart';
import '../entity/daily_revenue_confirmation_dto.dart';
import 'widgets/branch_dashboard_content.dart';
import 'widgets/daily_revenue_confirmation_dialog.dart';

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
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            onPressed: () => _showMessage(AppStrings.addRecordUnavailable),
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: EdgeInsets.all(mobile ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              children: [
                AppPageHeader(
                  title: AppStrings.branchManagerDashboard,
                  subtitle: state is BranchDashboardLoadSuccess
                      ? '${AppStrings.dashboardSubtitle} — ${state.dashboard.branchName}'
                      : AppStrings.dashboardSubtitle,
                  searchHint: AppStrings.searchAnalytics,
                  onSearchChanged: (value) => context
                      .read<BranchDashboardBloc>()
                      .add(BranchDashboardSearchChanged(value)),
                  actions: [
                    FilledButton.icon(
                      onPressed: state is BranchDashboardLoadSuccess
                          ? () => _showConfirmation(state)
                          : null,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text(AppStrings.confirmDailyRevenue),
                    ),
                  ],
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
        onUpdateRoster: () => _showMessage(AppStrings.rosterUnavailable),
        onFilterAlerts: () => context.read<BranchDashboardBloc>().add(
          const BranchDashboardSearchChanged('Critical'),
        ),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
