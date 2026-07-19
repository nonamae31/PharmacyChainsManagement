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
import '../entity/staff_management_dto.dart';
import '../entity/staff_performance_dto.dart';
import 'widgets/staff_performance_content.dart';
import 'widgets/staff_management_dialogs.dart';

class StaffPerformanceScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const StaffPerformanceScreen({super.key, this.onProfileTap});

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
    return BlocConsumer<StaffPerformanceBloc, StaffPerformanceState>(
      listener: (context, state) {
        if (state is StaffPerformanceOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is StaffPerformanceOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
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
                  title: AppStrings.staffPerformanceTitle,
                  subtitle: AppStrings.staffPerformanceSubtitle,
                  onProfileTap: widget.onProfileTap,
                  searchHint: AppStrings.searchStaff,
                  onSearchChanged: (value) => _search(state, value),
                  actions: [
                    OutlinedButton.icon(
                      onPressed: state is StaffPerformanceLoadSuccess
                          ? () => _showFilter(state)
                          : null,
                      icon: const Icon(Icons.filter_list),
                      label: const Text(AppStrings.filter),
                    ),
                    OutlinedButton.icon(
                      onPressed: state is StaffPerformanceLoadSuccess
                          ? _showCreateStaff
                          : null,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text(AppStrings.addStaff),
                    ),
                    FilledButton.icon(
                      onPressed:
                          state is StaffPerformanceLoadSuccess &&
                              state.performance.staff.isNotEmpty
                          ? () => _showAssessment(state.performance.staff)
                          : null,
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
        StaffPerformanceContent(
          performance: performance,
          shifts: state.shifts,
          shiftDate: state.shiftDate,
          payroll: state.payroll,
          onShiftDateSelected: (date) => context
              .read<StaffPerformanceBloc>()
              .add(StaffShiftDateSelected(date)),
        ),
    };
  }

  void _search(StaffPerformanceState state, String value) {
    if (state is! StaffPerformanceLoadSuccess) return;
    context.read<StaffPerformanceBloc>().add(
      StaffPerformanceFetchRequested(
        search: value,
        status: state.status,
        sort: state.sort,
        shiftDate: state.shiftDate,
      ),
    );
  }

  Future<void> _showFilter(StaffPerformanceLoadSuccess state) async {
    final selection = await showDialog<StaffFilterSelection>(
      context: context,
      builder: (_) => StaffFilterDialog(
        initialStatus: state.status,
        initialSort: state.sort,
      ),
    );
    if (selection == null || !mounted) return;
    context.read<StaffPerformanceBloc>().add(
      StaffPerformanceFetchRequested(
        search: state.search,
        status: selection.status,
        sort: selection.sort,
        shiftDate: state.shiftDate,
      ),
    );
  }

  Future<void> _showCreateStaff() async {
    final request = await showDialog<CreateBranchStaffRequestDto>(
      context: context,
      builder: (_) => const CreateStaffDialog(),
    );
    if (request != null && mounted) {
      context.read<StaffPerformanceBloc>().add(
        BranchStaffCreateRequested(request),
      );
    }
  }

  Future<void> _showAssessment(List<StaffPerformanceRowDto> staff) async {
    final request = await showDialog<CreateStaffAssessmentRequestDto>(
      context: context,
      builder: (_) => StaffAssessmentDialog(staff: staff),
    );
    if (request != null && mounted) {
      context.read<StaffPerformanceBloc>().add(
        StaffAssessmentCreateRequested(request),
      );
    }
  }
}
