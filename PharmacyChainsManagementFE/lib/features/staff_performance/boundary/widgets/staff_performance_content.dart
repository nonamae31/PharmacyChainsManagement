import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_responsive_metric_grid.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../control/staff_performance_bloc.dart';
import '../../control/staff_performance_event.dart';
import '../../entity/staff_management_dto.dart';
import '../../entity/staff_performance_dto.dart';
import '../../entity/staff_payroll_dto.dart';
import 'staff_payroll_panel.dart';
import 'staff_shift_roster_panel.dart';

class StaffPerformanceContent extends StatelessWidget {
  final StaffPerformanceDto performance;
  final List<StaffShiftDto> shifts;
  final DateTime shiftDate;
  final ValueChanged<DateTime> onShiftDateSelected;
  final StaffPayrollSummaryDto payroll;

  const StaffPerformanceContent({
    super.key,
    required this.performance,
    required this.shifts,
    required this.shiftDate,
    required this.onShiftDateSelected,
    required this.payroll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppResponsiveMetricGrid(
            children: [
              AppMetricCard(
                label: AppStrings.averageSalesTarget,
                value: _percent(performance.averageSalesTargetPercent),
                icon: Icons.trending_up,
              ),
              AppMetricCard(
                label: AppStrings.customerSatisfaction,
                value: performance.customerSatisfaction == null
                    ? AppStrings.unavailable
                    : '${performance.customerSatisfaction!.toStringAsFixed(1)}/5',
                icon: Icons.star_outline,
              ),
              AppMetricCard(
                label: AppStrings.teamAttendance,
                value: _percent(performance.teamAttendancePercent),
                icon: Icons.fact_check_outlined,
              ),
              _TopPerformerCard(topPerformer: performance.topPerformer),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _StaffMatrix(performance: performance),
          const SizedBox(height: AppSpacing.md),
          StaffShiftRosterPanel(
            staff: performance.staff,
            shifts: shifts,
            selectedDate: shiftDate,
            onDateSelected: onShiftDateSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          StaffPayrollPanel(payroll: payroll),
          const SizedBox(height: AppSpacing.md),
          _FeedbackPanel(performance: performance),
        ],
      ),
    );
  }

  String _percent(double? value) => value == null
      ? AppStrings.unavailable
      : '${value.toStringAsFixed(1)}${AppStrings.percentSymbol}';
}

class _TopPerformerCard extends StatelessWidget {
  final StaffPerformanceRowDto? topPerformer;

  const _TopPerformerCard({required this.topPerformer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.metricHeight,
      child: AppSectionCard(
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.topPerformer,
              style: AppTextStyles.metricLabel,
            ),
            const Spacer(),
            Text(
              topPerformer?.fullName ?? AppStrings.unavailable,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.surface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              topPerformer == null
                  ? AppStrings.unavailable
                  : '${AppStrings.salesRevenueLabel}: ${AppStrings.currencySymbol}${topPerformer!.salesRevenue.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.tealSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffMatrix extends StatelessWidget {
  final StaffPerformanceDto performance;

  const _StaffMatrix({required this.performance});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.staffPerformanceMatrix,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              Text(
                '${performance.staff.length} ${AppStrings.activeTeam}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (performance.staff.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
                  ? _StaffMobileList(staff: performance.staff)
                  : _StaffTable(staff: performance.staff),
            ),
        ],
      ),
    );
  }
}

class _StaffMobileList extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;

  const _StaffMobileList({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final member in staff) ...[
          AppMobileDetailCard(
            title: member.fullName,
            subtitle: member.roleName,
            leading: CircleAvatar(
              backgroundColor: AppColors.tealSoft,
              child: Text(
                member.fullName.isEmpty ? '' : member.fullName[0],
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppStatusChip(label: member.status),
                const SizedBox(height: AppSpacing.xxs),
                _StaffStatusAction(staff: member),
              ],
            ),
            details: [
              AppMobileDetailItem(
                label: AppStrings.salesRevenueLabel,
                value:
                    '${AppStrings.currencySymbol}${member.salesRevenue.toStringAsFixed(0)}',
              ),
              AppMobileDetailItem(
                label: AppStrings.lastAssessment,
                value: member.assessmentDate == null
                    ? AppStrings.unavailable
                    : MaterialLocalizations.of(
                        context,
                      ).formatCompactDate(member.assessmentDate!.toLocal()),
              ),
              AppMobileDetailItem(
                label: AppStrings.salesTarget,
                value: member.salesTarget == null
                    ? AppStrings.unavailable
                    : '${AppStrings.currencySymbol}${member.salesTarget!.toStringAsFixed(0)}',
              ),
              AppMobileDetailItem(
                label: AppStrings.targetProgress,
                value: member.targetProgressPercent == null
                    ? AppStrings.unavailable
                    : '${member.targetProgressPercent!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
              ),
              AppMobileDetailItem(
                label: AppStrings.customerRating,
                value:
                    member.customerRating?.toStringAsFixed(1) ??
                    AppStrings.unavailable,
              ),
              AppMobileDetailItem(
                label: AppStrings.attendance,
                value: member.attendancePercent == null
                    ? AppStrings.unavailable
                    : '${member.attendancePercent!.toStringAsFixed(0)}${AppStrings.percentSymbol}',
              ),
              AppMobileDetailItem(
                label: AppStrings.performance,
                value: member.performanceScore == null
                    ? AppStrings.unavailable
                    : '${member.performanceScore!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _StaffTable extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;

  const _StaffTable({required this.staff});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text(AppStrings.teamMember)),
          DataColumn(label: SizedBox.shrink()),
          DataColumn(label: Text(AppStrings.status)),
          DataColumn(label: Text(AppStrings.lastAssessment)),
          DataColumn(label: Text(AppStrings.salesTarget)),
          DataColumn(label: Text(AppStrings.targetProgress)),
          DataColumn(label: Text(AppStrings.customerRating)),
          DataColumn(label: Text(AppStrings.attendance)),
          DataColumn(label: Text(AppStrings.performance)),
        ],
        rows: staff
            .map((member) => _buildRow(context, member))
            .toList(growable: false),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, StaffPerformanceRowDto member) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.md,
                backgroundColor: AppColors.tealSoft,
                child: Text(
                  member.fullName.isEmpty ? '' : member.fullName[0],
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(member.roleName, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
        DataCell(_StaffStatusAction(staff: member)),
        DataCell(AppStatusChip(label: member.status)),
        DataCell(
          Text(
            member.assessmentDate == null
                ? AppStrings.unavailable
                : MaterialLocalizations.of(
                    context,
                  ).formatCompactDate(member.assessmentDate!.toLocal()),
          ),
        ),
        DataCell(
          Text(
            '${AppStrings.currencySymbol}${member.salesRevenue.toStringAsFixed(0)} / ${member.salesTarget == null ? AppStrings.unavailable : '${AppStrings.currencySymbol}${member.salesTarget!.toStringAsFixed(0)}'}',
          ),
        ),
        DataCell(
          member.targetProgressPercent == null
              ? const Text(AppStrings.unavailable)
              : SizedBox(
                  width: AppSpacing.progressWidth,
                  child: LinearProgressIndicator(
                    value: (member.targetProgressPercent! / 100)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                    color: member.targetProgressPercent! < 70
                        ? AppColors.danger
                        : AppColors.primary,
                    backgroundColor: AppColors.border,
                  ),
                ),
        ),
        DataCell(
          Text(
            member.customerRating?.toStringAsFixed(1) ?? AppStrings.unavailable,
          ),
        ),
        DataCell(
          Text(
            member.attendancePercent == null
                ? AppStrings.unavailable
                : '${member.attendancePercent!.toStringAsFixed(0)}${AppStrings.percentSymbol}',
          ),
        ),
        DataCell(
          Text(
            member.performanceScore == null
                ? AppStrings.unavailable
                : '${member.performanceScore!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffStatusAction extends StatelessWidget {
  final StaffPerformanceRowDto staff;

  const _StaffStatusAction({required this.staff});

  bool get _isActive => staff.status.toUpperCase() == 'ACTIVE';

  @override
  Widget build(BuildContext context) {
    final label = _isActive
        ? AppStrings.deactivateStaff
        : AppStrings.activateStaff;
    final icon = _isActive ? Icons.person_off_outlined : Icons.person_outline;
    final color = _isActive ? AppColors.danger : AppColors.success;
    return IconButton(
      tooltip: label,
      icon: Icon(icon, color: color),
      onPressed: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    final bloc = context.read<StaffPerformanceBloc>();
    if (_isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppStrings.deactivateStaff),
          content: Text(
            '${staff.fullName}\n\n${AppStrings.deactivateStaffConfirmMessage}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.deactivateStaff),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    bloc.add(
      StaffStatusUpdateRequested(
        UpdateStaffStatusRequestDto(
          staffId: staff.staffId,
          status: _isActive ? 'INACTIVE' : 'ACTIVE',
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final StaffPerformanceDto performance;

  const _FeedbackPanel({required this.performance});

  @override
  Widget build(BuildContext context) {
    final feedback = performance.recentFeedback;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.recentFeedback,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          if (feedback.isEmpty)
            const Text(AppStrings.noFeedbackData, style: AppTextStyles.body)
          else
            for (final item in feedback) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.primary,
                ),
                title: Text(item.staffName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatCompactDate(item.assessmentDate.toLocal()),
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      item.notes.isEmpty
                          ? AppStrings.noAssessmentNotes
                          : item.notes,
                    ),
                  ],
                ),
                trailing: Text(
                  '${item.performanceScore.toStringAsFixed(0)}${AppStrings.percentSymbol}',
                  style: AppTextStyles.body,
                ),
              ),
              const Divider(height: AppSpacing.hairline),
            ],
        ],
      ),
    );
  }
}
