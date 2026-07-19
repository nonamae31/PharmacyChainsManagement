import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/csv_download_service.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../control/branch_revenue_bloc.dart';
import '../control/branch_revenue_event.dart';
import '../control/branch_revenue_state.dart';
import 'widgets/branch_revenue_content.dart';

class BranchRevenueScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const BranchRevenueScreen({super.key, this.onProfileTap});

  @override
  State<BranchRevenueScreen> createState() => _BranchRevenueScreenState();
}

class _BranchRevenueScreenState extends State<BranchRevenueScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchRevenueBloc>().add(
      const BranchRevenueFetchRequested(period: 'daily'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BranchRevenueBloc, BranchRevenueState>(
      listener: (context, state) {
        if (state is BranchRevenueExportSuccess) {
          downloadCsv(state.bytes, AppStrings.revenueCsvFile);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStrings.exportReady)));
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
                  title: AppStrings.branchRevenueTitle,
                  subtitle: AppStrings.revenueStatisticsSubtitle,
                  onProfileTap: widget.onProfileTap,
                  actions: [
                    FilledButton.icon(
                      onPressed: state is BranchRevenueLoadSuccess
                          ? () => context.read<BranchRevenueBloc>().add(
                              const BranchRevenueExportRequested(),
                            )
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text(AppStrings.exportReport),
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

  Widget _buildBody(BranchRevenueState state) {
    return switch (state) {
      BranchRevenueInitial() ||
      BranchRevenueLoading() => const AppLoadingIndicator(),
      BranchRevenueLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => context.read<BranchRevenueBloc>().add(
          const BranchRevenueFetchRequested(period: 'daily'),
        ),
      ),
      BranchRevenueLoadSuccess() => BranchRevenueContent(
        state: state,
        onPeriodSelected: _selectPeriod,
      ),
    };
  }

  Future<void> _selectPeriod(String period) async {
    if (period != 'custom') {
      context.read<BranchRevenueBloc>().add(
        BranchRevenueFetchRequested(period: period),
      );
      return;
    }
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: AppStrings.selectDateRange,
    );
    if (range != null && mounted) {
      context.read<BranchRevenueBloc>().add(
        BranchRevenueFetchRequested(
          period: period,
          fromDate: range.start,
          toDate: range.end,
        ),
      );
    }
  }
}
