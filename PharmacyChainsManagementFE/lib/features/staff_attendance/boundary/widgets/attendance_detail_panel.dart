import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/primary_button.dart';
import '../../entity/attendance_record_dto.dart';

class AttendanceDetailPanel extends StatelessWidget {
  final DateTime selectedDate;
  final AttendanceRecordDto? record;
  final bool canCheckIn;
  final bool checkInInProgress;
  final VoidCallback onCheckIn;
  final bool canCheckOut;
  final bool checkOutInProgress;
  final VoidCallback onCheckOut;

  const AttendanceDetailPanel({
    super.key,
    required this.selectedDate,
    required this.record,
    required this.canCheckIn,
    required this.checkInInProgress,
    required this.onCheckIn,
    required this.canCheckOut,
    required this.checkOutInProgress,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) => AppSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat.yMMMMEEEEd().format(selectedDate),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DetailRow(
          label: AppStrings.attendanceStatus,
          value: record?.status ?? AppStrings.attendanceNotCheckedIn,
          icon: record == null ? Icons.pending_outlined : Icons.check_circle,
          color: record == null ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailRow(
          label: AppStrings.attendanceCheckInTime,
          value: _time(record?.checkInTime),
          icon: Icons.login,
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailRow(
          label: AppStrings.attendanceCheckOutTime,
          value: _time(record?.checkOutTime),
          icon: Icons.logout,
        ),
        if (canCheckIn) ...[
          const Spacer(),
          PrimaryButton(
            text: AppStrings.attendanceCheckIn,
            isLoading: checkInInProgress,
            onPressed: onCheckIn,
          ),
        ] else if (canCheckOut) ...[
          const Spacer(),
          PrimaryButton(
            text: AppStrings.attendanceCheckOut,
            isLoading: checkOutInProgress,
            onPressed: onCheckOut,
          ),
        ],
      ],
    ),
  );

  String _time(DateTime? value) => value == null
      ? AppStrings.notAvailable
      : DateFormat.Hm().format(value.toLocal());
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(label)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}
