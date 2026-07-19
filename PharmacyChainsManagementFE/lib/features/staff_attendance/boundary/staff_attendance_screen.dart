import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../injection_container.dart';
import '../../../shared/shared_components/app_error_snack_bar.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../staff_sales/boundary/widgets/staff_workspace_shell.dart';
import '../control/staff_attendance_bloc.dart';
import '../control/staff_attendance_event.dart';
import '../control/staff_attendance_state.dart';
import 'widgets/attendance_calendar.dart';
import 'widgets/attendance_detail_dialog.dart';

class StaffAttendanceScreen extends StatelessWidget {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobileView = _usesMobileCalendar;
    return BlocProvider(
      create: (_) => sl<StaffAttendanceBloc>()
        ..add(
          StaffAttendanceFetchRequested(
            focusedDate: DateTime.now(),
            mobileView: mobileView,
          ),
        ),
      child: StaffWorkspaceShell(
        title: AppStrings.attendanceTitle,
        subtitle: AppStrings.attendanceSubtitle,
        section: StaffWorkspaceSection.attendance,
        child: const _StaffAttendanceContent(),
      ),
    );
  }

  static bool get _usesMobileCalendar =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

class _StaffAttendanceContent extends StatelessWidget {
  const _StaffAttendanceContent();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<StaffAttendanceBloc, StaffAttendanceState>(
        listener: (context, state) {
          if (state case StaffAttendanceLoadSuccess(
            operationMessage: final String message,
          )) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          } else if (state case StaffAttendanceLoadSuccess(
            detailRequested: true,
            selectedDate: final selectedDate,
          )) {
            final bloc = context.read<StaffAttendanceBloc>();
            bloc.add(const StaffAttendanceDetailPresented());
            showDialog<void>(
              context: context,
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: AttendanceDetailDialog(selectedDate: selectedDate),
              ),
            );
          } else if (state case StaffAttendanceLoadFailure(:final message)) {
            showAppErrorSnackBar(context, message: message);
          }
        },
        builder: (context, state) => switch (state) {
          StaffAttendanceInitial() ||
          StaffAttendanceLoading() => const AppLoadingIndicator(),
          StaffAttendanceLoadFailure(:final message) => AppErrorView(
            message: message,
            onRetry: () => context.read<StaffAttendanceBloc>().add(
              StaffAttendanceFetchRequested(
                focusedDate: DateTime.now(),
                mobileView: StaffAttendanceScreen._usesMobileCalendar,
              ),
            ),
          ),
          StaffAttendanceLoadSuccess() => _AttendanceLoaded(state: state),
        },
      );

}

class _AttendanceLoaded extends StatelessWidget {
  final StaffAttendanceLoadSuccess state;

  const _AttendanceLoaded({required this.state});

  @override
  Widget build(BuildContext context) {
    final calendar = AttendanceCalendar(
      mobileView: state.mobileView,
      focusedDate: state.focusedDate,
      selectedDate: state.selectedDate,
      dates: state.visibleDates,
      records: state.records,
      onDateSelected: (date) => context
          .read<StaffAttendanceBloc>()
          .add(StaffAttendanceDateSelected(date)),
      onPrevious: () => context
          .read<StaffAttendanceBloc>()
          .add(const StaffAttendancePeriodChanged(-1)),
      onNext: () => context
          .read<StaffAttendanceBloc>()
          .add(const StaffAttendancePeriodChanged(1)),
    );
    return calendar;
  }
}
