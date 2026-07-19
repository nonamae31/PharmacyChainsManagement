import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../control/staff_attendance_bloc.dart';
import '../../control/staff_attendance_event.dart';
import '../../control/staff_attendance_state.dart';
import 'attendance_detail_panel.dart';

class AttendanceDetailDialog extends StatelessWidget {
  final DateTime selectedDate;

  const AttendanceDetailDialog({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: AppSpacing.attendanceDialogWidth,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: BlocBuilder<StaffAttendanceBloc, StaffAttendanceState>(
          builder: (context, state) {
            if (state is! StaffAttendanceLoadSuccess) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: AppStrings.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                SizedBox(
                  height: AppSpacing.attendanceDetailHeight,
                  child: AttendanceDetailPanel(
                    selectedDate: selectedDate,
                    record: state.selectedRecord,
                    canCheckIn: state.canCheckIn,
                    checkInInProgress: state.checkInInProgress,
                    onCheckIn: () => context
                        .read<StaffAttendanceBloc>()
                        .add(const StaffAttendanceCheckInSubmitted()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
