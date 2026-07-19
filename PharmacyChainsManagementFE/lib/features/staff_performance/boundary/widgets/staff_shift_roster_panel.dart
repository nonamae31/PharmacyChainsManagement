import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/constants/branch_manager_validation_rules.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../entity/staff_management_dto.dart';
import '../../entity/staff_performance_dto.dart';

class StaffShiftRosterPanel extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final List<StaffShiftDto> shifts;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const StaffShiftRosterPanel({
    super.key,
    required this.staff,
    required this.shifts,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => selectedDate.add(Duration(days: index)),
      growable: false,
    );
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShiftRosterHeader(
            weekStart: selectedDate,
            onPreviousWeek: () => onDateSelected(
              selectedDate.subtract(const Duration(days: DateTime.daysPerWeek)),
            ),
            onNextWeek: () => onDateSelected(
              selectedDate.add(const Duration(days: DateTime.daysPerWeek)),
            ),
            onSelectWeek: () => _selectWeek(context),
          ),
          const SizedBox(height: AppSpacing.md),
          if (staff.isEmpty)
            const AppEmptyState(message: AppStrings.noShiftsForDate)
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
                  ? _MobileWeeklyShiftList(
                      staff: staff,
                      shifts: shifts,
                      weekDates: weekDates,
                    )
                  : _WeeklyShiftTable(
                      staff: staff,
                      shifts: shifts,
                      weekDates: weekDates,
                    ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectWeek(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(
        BranchManagerValidationRules.earliestSupportedDateYear,
      ),
      lastDate: DateTime(
        today.year + BranchManagerValidationRules.maximumSchedulingYears,
        today.month,
        today.day,
      ),
      helpText: AppStrings.selectShiftDate,
    );
    if (date != null && context.mounted) onDateSelected(date);
  }
}

class _ShiftRosterHeader extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onSelectWeek;

  const _ShiftRosterHeader({
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onSelectWeek,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final weekEnd = weekStart.add(
      const Duration(days: DateTime.daysPerWeek - 1),
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.shiftRosterTitle, style: AppTextStyles.sectionTitle),
            SizedBox(height: AppSpacing.xxs),
            Text(AppStrings.shiftRosterSubtitle, style: AppTextStyles.caption),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: AppStrings.previousWeek,
              onPressed: onPreviousWeek,
              icon: const Icon(Icons.chevron_left),
            ),
            OutlinedButton.icon(
              onPressed: onSelectWeek,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                '${localizations.formatCompactDate(weekStart)} - '
                '${localizations.formatCompactDate(weekEnd)}',
              ),
            ),
            IconButton(
              tooltip: AppStrings.nextWeek,
              onPressed: onNextWeek,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileWeeklyShiftList extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final List<StaffShiftDto> shifts;
  final List<DateTime> weekDates;

  const _MobileWeeklyShiftList({
    required this.staff,
    required this.shifts,
    required this.weekDates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final member in staff) ...[
          AppMobileDetailCard(
            title: member.fullName,
            subtitle: AppStrings.weeklySchedule,
            leading: const Icon(
              Icons.date_range_outlined,
              color: AppColors.primary,
            ),
            details: [
              for (final date in weekDates)
                AppMobileDetailItem(
                  label: _dateHeading(context, date),
                  value: _shiftDescription(
                    context,
                    _findShift(shifts, member.staffId, date),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _WeeklyShiftTable extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final List<StaffShiftDto> shifts;
  final List<DateTime> weekDates;

  const _WeeklyShiftTable({
    required this.staff,
    required this.shifts,
    required this.weekDates,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text(AppStrings.teamMember)),
          for (final date in weekDates)
            DataColumn(label: Text(_dateHeading(context, date))),
        ],
        rows: staff
            .map(
              (member) => DataRow(
                cells: [
                  DataCell(Text(member.fullName)),
                  for (final date in weekDates)
                    DataCell(
                      _ShiftCell(
                        shift: _findShift(shifts, member.staffId, date),
                      ),
                    ),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ShiftCell extends StatelessWidget {
  final StaffShiftDto? shift;

  const _ShiftCell({required this.shift});

  @override
  Widget build(BuildContext context) {
    final value = shift;
    if (value == null) {
      return const Text(
        AppStrings.notAssigned,
        style: AppTextStyles.caption,
      );
    }
    final isOff = value.status == 'OFF' || value.status == 'CANCELLED';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOff ? _statusLabel(value.status) : _formatShiftTime(context, value),
          style: AppTextStyles.body.copyWith(
            color: isOff ? AppColors.textSecondary : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (value.isRecurring && !isOff)
          const Text(AppStrings.weekly, style: AppTextStyles.caption),
      ],
    );
  }
}

StaffShiftDto? _findShift(
  List<StaffShiftDto> shifts,
  String staffId,
  DateTime date,
) {
  for (final shift in shifts) {
    if (shift.staffId == staffId && DateUtils.isSameDay(shift.shiftDate, date)) {
      return shift;
    }
  }
  return null;
}

String _shiftDescription(BuildContext context, StaffShiftDto? shift) {
  if (shift == null) return AppStrings.notAssigned;
  if (shift.status == 'OFF' || shift.status == 'CANCELLED') {
    return _statusLabel(shift.status);
  }
  final time = _formatShiftTime(context, shift);
  return shift.isRecurring ? '$time (${AppStrings.weekly})' : time;
}

String _formatShiftTime(BuildContext context, StaffShiftDto shift) {
  final localizations = MaterialLocalizations.of(context);
  final start = localizations.formatTimeOfDay(
    TimeOfDay(hour: shift.startTime.hour, minute: shift.startTime.minute),
  );
  final end = localizations.formatTimeOfDay(
    TimeOfDay(hour: shift.endTime.hour, minute: shift.endTime.minute),
  );
  return '$start - $end';
}

String _statusLabel(String status) => switch (status) {
  'OFF' => AppStrings.dayOff,
  'CANCELLED' => AppStrings.cancelled,
  _ => AppStrings.scheduled,
};

String _dateHeading(BuildContext context, DateTime date) {
  final weekday = switch (date.weekday) {
    DateTime.monday => AppStrings.mondayShort,
    DateTime.tuesday => AppStrings.tuesdayShort,
    DateTime.wednesday => AppStrings.wednesdayShort,
    DateTime.thursday => AppStrings.thursdayShort,
    DateTime.friday => AppStrings.fridayShort,
    DateTime.saturday => AppStrings.saturdayShort,
    _ => AppStrings.sundayShort,
  };
  return '$weekday ${MaterialLocalizations.of(context).formatCompactDate(date)}';
}
