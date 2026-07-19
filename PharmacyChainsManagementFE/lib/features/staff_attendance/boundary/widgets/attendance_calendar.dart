import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../entity/attendance_record_dto.dart';

class AttendanceCalendar extends StatelessWidget {
  final bool mobileView;
  final DateTime focusedDate;
  final DateTime selectedDate;
  final List<DateTime> dates;
  final List<AttendanceRecordDto> records;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const AttendanceCalendar({
    super.key,
    required this.mobileView,
    required this.focusedDate,
    required this.selectedDate,
    required this.dates,
    required this.records,
    required this.onDateSelected,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _CalendarHeader(
        title: mobileView
            ? '${DateFormat.MMMd().format(dates.first)} - '
                  '${DateFormat.yMMMd().format(dates.last)}'
            : DateFormat.yMMMM().format(focusedDate),
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      const SizedBox(height: AppSpacing.md),
      Expanded(
        child: mobileView
            ? ListView.separated(
                itemCount: dates.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) => _DateTile(
                  date: dates[index],
                  selected: _sameDay(dates[index], selectedDate),
                  record: _recordFor(dates[index]),
                  mobileView: true,
                  onTap: () => onDateSelected(dates[index]),
                ),
              )
            : _MonthGrid(
                dates: dates,
                selectedDate: selectedDate,
                recordFor: _recordFor,
                onDateSelected: onDateSelected,
              ),
      ),
    ],
  );

  AttendanceRecordDto? _recordFor(DateTime date) {
    for (final record in records) {
      if (_sameDay(record.attendanceDate, date)) return record;
    }
    return null;
  }

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class _CalendarHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: AppStrings.attendancePreviousPeriod,
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left),
      ),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        tooltip: AppStrings.attendanceNextPeriod,
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class _MonthGrid extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final AttendanceRecordDto? Function(DateTime) recordFor;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthGrid({
    required this.dates,
    required this.selectedDate,
    required this.recordFor,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final leadingEmptyDays = dates.first.weekday - DateTime.monday;
    final itemCount = leadingEmptyDays + dates.length;
    return Column(
      children: [
        Row(
          children: [
            for (final label in AppStrings.attendanceWeekdayLabels)
              Expanded(child: Center(child: Text(label))),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DateTime.daysPerWeek,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: itemCount,
            itemBuilder: (_, index) {
              if (index < leadingEmptyDays) return const SizedBox.shrink();
              final date = dates[index - leadingEmptyDays];
              return _DateTile(
                date: date,
                selected: AttendanceCalendar._sameDay(date, selectedDate),
                record: recordFor(date),
                mobileView: false,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final AttendanceRecordDto? record;
  final bool mobileView;
  final VoidCallback onTap;

  const _DateTile({
    required this.date,
    required this.selected,
    required this.record,
    required this.mobileView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surface,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: mobileView
            ? Row(
                children: [
                  SizedBox(
                    width: AppSpacing.xxxl,
                    child: Text(
                      DateFormat.E().format(date),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(DateFormat.MMMd().format(date)),
                  const Spacer(),
                  _AttendanceDot(
                    attended: record != null,
                    showLabel: true,
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      DateFormat.d().format(date),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _AttendanceDot(
                      attended: record != null,
                      showLabel: false,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

class _AttendanceDot extends StatelessWidget {
  final bool attended;
  final bool showLabel;

  const _AttendanceDot({
    required this.attended,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(
          color: attended ? AppColors.success : AppColors.textHint,
          shape: BoxShape.circle,
        ),
      ),
      if (attended && showLabel) ...[
        const SizedBox(width: AppSpacing.xs),
        const Text(AppStrings.attendanceCheckedInShort),
      ],
    ],
  );
}
