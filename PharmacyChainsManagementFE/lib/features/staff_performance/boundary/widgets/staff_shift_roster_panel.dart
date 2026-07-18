import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../entity/staff_management_dto.dart';

class StaffShiftRosterPanel extends StatelessWidget {
  final List<StaffShiftDto> shifts;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const StaffShiftRosterPanel({
    super.key,
    required this.shifts,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              const _ShiftRosterHeading(),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatCompactDate(selectedDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (shifts.isEmpty)
            const AppEmptyState(message: AppStrings.noShiftsForDate)
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
                  ? _MobileShiftList(shifts: shifts)
                  : _ShiftTable(shifts: shifts),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate.subtract(const Duration(days: 1825)),
      lastDate: selectedDate.add(const Duration(days: 1825)),
      helpText: AppStrings.selectShiftDate,
    );
    if (date != null && context.mounted) {
      onDateSelected(date);
    }
  }
}

class _ShiftRosterHeading extends StatelessWidget {
  const _ShiftRosterHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.shiftRosterTitle, style: AppTextStyles.sectionTitle),
        SizedBox(height: AppSpacing.xxs),
        Text(AppStrings.shiftRosterSubtitle, style: AppTextStyles.caption),
      ],
    );
  }
}

class _MobileShiftList extends StatelessWidget {
  final List<StaffShiftDto> shifts;

  const _MobileShiftList({required this.shifts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final shift in shifts) ...[
          AppMobileDetailCard(
            title: shift.staffName,
            subtitle: _formatShiftTime(context, shift),
            leading: const Icon(
              Icons.schedule_outlined,
              color: AppColors.primary,
            ),
            trailing: AppStatusChip(label: shift.status),
            details: [
              AppMobileDetailItem(
                label: AppStrings.notes,
                value: _shiftNotes(shift),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ShiftTable extends StatelessWidget {
  final List<StaffShiftDto> shifts;

  const _ShiftTable({required this.shifts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text(AppStrings.teamMember)),
          DataColumn(label: Text(AppStrings.shiftTime)),
          DataColumn(label: Text(AppStrings.shiftStatus)),
          DataColumn(label: Text(AppStrings.notes)),
        ],
        rows: shifts
            .map(
              (shift) => DataRow(
                cells: [
                  DataCell(Text(shift.staffName)),
                  DataCell(Text(_formatShiftTime(context, shift))),
                  DataCell(AppStatusChip(label: shift.status)),
                  DataCell(Text(_shiftNotes(shift))),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

String _formatShiftTime(BuildContext context, StaffShiftDto shift) {
  final localizations = MaterialLocalizations.of(context);
  final start = localizations.formatTimeOfDay(
    TimeOfDay(hour: shift.startTime.hour, minute: shift.startTime.minute),
  );
  final end = localizations.formatTimeOfDay(
    TimeOfDay(hour: shift.endTime.hour, minute: shift.endTime.minute),
  );
  return '$start – $end';
}

String _shiftNotes(StaffShiftDto shift) {
  final notes = shift.notes?.trim() ?? '';
  return notes.isEmpty ? AppStrings.unavailable : notes;
}
