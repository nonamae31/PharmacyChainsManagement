import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../control/staff_performance_bloc.dart';
import '../control/staff_performance_event.dart';
import '../control/staff_performance_state.dart';
import 'widgets/staff_performance_content.dart';

class StaffPerformanceScreen extends StatefulWidget {
  const StaffPerformanceScreen({super.key});

  @override
  State<StaffPerformanceScreen> createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffPerformanceBloc>().add(
      const StaffPerformanceFetchRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffPerformanceBloc, StaffPerformanceState>(
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
                  title: AppStrings.staffPerformanceTitle,
                  subtitle: AppStrings.staffPerformanceSubtitle,
                  searchHint: AppStrings.searchStaff,
                  onSearchChanged: (value) => context
                      .read<StaffPerformanceBloc>()
                      .add(StaffPerformanceFetchRequested(search: value)),
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => context.read<StaffPerformanceBloc>().add(
                        const StaffPerformanceFetchRequested(),
                      ),
                      icon: const Icon(Icons.filter_list),
                      label: const Text(AppStrings.filter),
                    ),
                    FilledButton.icon(
                      onPressed: () =>
                          _showMessage(AppStrings.assessmentUnavailable),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.newAssessment),
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

  Widget _buildBody(StaffPerformanceState state) {
    return switch (state) {
      StaffPerformanceInitial() ||
      StaffPerformanceLoading() => const AppLoadingIndicator(),
      StaffPerformanceLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => context.read<StaffPerformanceBloc>().add(
          const StaffPerformanceFetchRequested(),
        ),
      ),
      StaffPerformanceLoadSuccess(:final performance) =>
        StaffPerformanceContent(performance: performance),
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
