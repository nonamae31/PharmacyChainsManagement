import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/constants/branch_manager_validation_rules.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../control/staff_performance_bloc.dart';
import '../../control/staff_performance_event.dart';
import '../../entity/staff_payroll_dto.dart';

class StaffPayrollPanel extends StatelessWidget {
  final StaffPayrollSummaryDto payroll;

  const StaffPayrollPanel({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(payroll: payroll),
          const SizedBox(height: AppSpacing.md),
          _Summary(payroll: payroll),
          const SizedBox(height: AppSpacing.md),
          if (payroll.staff.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
                  ? _MobilePayrollList(payroll: payroll)
                  : _PayrollTable(payroll: payroll),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final StaffPayrollSummaryDto payroll;

  const _Header({required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.staffPayrollTitle,
                style: AppTextStyles.sectionTitle,
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                AppStrings.staffPayrollSubtitle,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.date_range_outlined),
          label: Text(
            '${_date(payroll.periodStart)} - ${_date(payroll.periodEnd)}',
          ),
          onPressed: () => _selectPeriod(context),
        ),
      ],
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(
        BranchManagerValidationRules.earliestSupportedDateYear,
      ),
      lastDate: today,
      initialDateRange: DateTimeRange(
        start: payroll.periodStart,
        end: payroll.periodEnd.isAfter(today) ? today : payroll.periodEnd,
      ),
    );
    if (selected == null || !context.mounted) return;
    context.read<StaffPerformanceBloc>().add(
      StaffPayrollPeriodSelected(
        fromDate: selected.start,
        toDate: selected.end,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final StaffPayrollSummaryDto payroll;

  const _Summary({required this.payroll});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        AppStrings.recordedWorkHours,
        '${payroll.totalCompletedHours.toStringAsFixed(2)} ${AppStrings.hourShort}',
      ),
      (
        AppStrings.totalLatePayReduction,
        '${_money(payroll.totalLatePayReduction)} '
            '(${payroll.totalLateMinutes} ${AppStrings.minuteShort})',
      ),
      (AppStrings.basePay, _money(payroll.totalBasePay)),
      (AppStrings.totalBonus, _money(payroll.totalBonus)),
      (AppStrings.totalDeduction, _money(payroll.totalDeduction)),
      (AppStrings.totalNetPay, _money(payroll.totalNetPay)),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (item) => Container(
              width: 170,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.$2,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MobilePayrollList extends StatelessWidget {
  final StaffPayrollSummaryDto payroll;

  const _MobilePayrollList({required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in payroll.staff) ...[
          AppMobileDetailCard(
            title: row.staffName,
            subtitle: row.hourlyRate == null
                ? AppStrings.payRateNotSet
                : '${_money(row.hourlyRate!)} / ${AppStrings.hourShort}',
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppStatusChip(label: row.status),
                _Actions(row: row, payroll: payroll),
              ],
            ),
            details: [
              AppMobileDetailItem(
                label: AppStrings.attendanceDays,
                value: '${row.attendanceDays}/${row.periodDays}',
              ),
              AppMobileDetailItem(
                label: AppStrings.lateDays,
                value: row.lateDays.toString(),
              ),
              AppMobileDetailItem(
                label: AppStrings.lateTime,
                value: '${row.lateMinutes} ${AppStrings.minuteShort}',
              ),
              AppMobileDetailItem(
                label: AppStrings.latePayReduction,
                value: _money(row.latePayReduction),
              ),
              AppMobileDetailItem(
                label: AppStrings.recordedWorkHours,
                value: row.completedHours.toStringAsFixed(2),
              ),
              AppMobileDetailItem(
                label: AppStrings.basePay,
                value: _money(row.basePay),
              ),
              AppMobileDetailItem(
                label: AppStrings.bonus,
                value: _money(row.bonus),
              ),
              AppMobileDetailItem(
                label: AppStrings.deduction,
                value: _money(row.deduction),
              ),
              AppMobileDetailItem(
                label: AppStrings.netPay,
                value: _money(row.netPay),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _PayrollTable extends StatelessWidget {
  final StaffPayrollSummaryDto payroll;

  const _PayrollTable({required this.payroll});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 60,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(label: Text(AppStrings.teamMember)),
          DataColumn(label: Text(AppStrings.hourlyRate)),
          DataColumn(label: Text(AppStrings.attendanceDays)),
          DataColumn(label: Text(AppStrings.latePayReduction)),
          DataColumn(label: Text(AppStrings.recordedWorkHours)),
          DataColumn(label: Text(AppStrings.basePay)),
          DataColumn(label: Text(AppStrings.bonus)),
          DataColumn(label: Text(AppStrings.deduction)),
          DataColumn(label: Text(AppStrings.netPay)),
          DataColumn(label: Text(AppStrings.status)),
          DataColumn(label: Text(AppStrings.payrollActions)),
        ],
        rows: payroll.staff
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row.staffName)),
                  DataCell(
                    Text(
                      row.hourlyRate == null
                          ? AppStrings.unavailable
                          : _money(row.hourlyRate!),
                    ),
                  ),
                  DataCell(_AttendanceSummary(row: row)),
                  DataCell(_LateReductionSummary(row: row)),
                  DataCell(Text(row.completedHours.toStringAsFixed(2))),
                  DataCell(Text(_money(row.basePay))),
                  DataCell(Text(_money(row.bonus))),
                  DataCell(Text(_money(row.deduction))),
                  DataCell(Text(_money(row.netPay))),
                  DataCell(AppStatusChip(label: row.status)),
                  DataCell(_Actions(row: row, payroll: payroll)),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final StaffPayrollRowDto row;
  final StaffPayrollSummaryDto payroll;

  const _Actions({required this.row, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: AppStrings.setHourlyRate,
          icon: const Icon(Icons.payments_outlined),
          onPressed: row.isConfirmed ? null : () => _setRate(context),
        ),
        IconButton(
          tooltip: AppStrings.viewAttendanceDetails,
          icon: const Icon(Icons.fact_check_outlined),
          onPressed: row.attendanceRecords.isEmpty
              ? null
              : () => _showAttendanceDetails(context, row),
        ),
        IconButton(
          tooltip: row.completedHours <= 0
              ? AppStrings.attendanceHoursMissing
              : AppStrings.calculatePayroll,
          icon: const Icon(Icons.calculate_outlined),
          onPressed:
              row.isConfirmed ||
                  row.hourlyRate == null ||
                  row.completedHours <= 0
              ? null
              : () => _editPayroll(context),
        ),
      ],
    );
  }

  Future<void> _setRate(BuildContext context) async {
    final request = await showDialog<UpdateStaffPayRateRequestDto>(
      context: context,
      builder: (_) =>
          _PayRateDialog(row: row, effectiveFrom: payroll.periodStart),
    );
    if (request == null || !context.mounted) return;
    context.read<StaffPerformanceBloc>().add(
      StaffPayRateUpsertRequested(request),
    );
  }

  Future<void> _editPayroll(BuildContext context) async {
    final request = await showDialog<UpsertStaffPayrollRequestDto>(
      context: context,
      builder: (_) => _PayrollDialog(row: row, payroll: payroll),
    );
    if (request == null || !context.mounted) return;
    context.read<StaffPerformanceBloc>().add(
      StaffPayrollUpsertRequested(request),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  final StaffPayrollRowDto row;

  const _AttendanceSummary({required this.row});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: row.attendanceRecords.isEmpty
          ? null
          : () => _showAttendanceDetails(context, row),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${row.attendanceDays}/${row.periodDays}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${AppStrings.lateDays}: ${row.lateDays}',
              style: AppTextStyles.caption.copyWith(
                color: row.lateDays > 0
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LateReductionSummary extends StatelessWidget {
  final StaffPayrollRowDto row;

  const _LateReductionSummary({required this.row});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _money(row.latePayReduction),
          style: AppTextStyles.body.copyWith(
            color: row.latePayReduction > 0
                ? AppColors.warning
                : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${row.lateMinutes} ${AppStrings.minuteShort}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

Future<void> _showAttendanceDetails(
  BuildContext context,
  StaffPayrollRowDto row,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AttendanceDetailsDialog(row: row),
  );
}

class _AttendanceDetailsDialog extends StatelessWidget {
  final StaffPayrollRowDto row;

  const _AttendanceDetailsDialog({required this.row});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${AppStrings.attendanceDetails}: ${row.staffName}'),
      content: SizedBox(
        width: AppSpacing.dialogWidthWide,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: row.attendanceRecords.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) =>
              _AttendanceRecordTile(record: row.attendanceRecords[index]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  final StaffPayrollAttendanceDayDto record;

  const _AttendanceRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isLate = record.status.toUpperCase() == AppStrings.lateStatus;
    final shift =
        record.scheduledStartTime == null || record.scheduledEndTime == null
        ? AppStrings.noShiftAssigned
        : '${_clockValue(record.scheduledStartTime!)} - '
              '${_clockValue(record.scheduledEndTime!)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLate ? Icons.schedule_outlined : Icons.check_circle_outline,
            color: isLate ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _date(record.attendanceDate),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      record.status,
                      style: AppTextStyles.caption.copyWith(
                        color: isLate ? AppColors.warning : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _AttendanceDetailLine(
                  label: AppStrings.checkIn,
                  value: _time(record.checkInTime),
                ),
                _AttendanceDetailLine(
                  label: AppStrings.checkOut,
                  value: record.checkOutTime == null
                      ? AppStrings.notCheckedOut
                      : _time(record.checkOutTime!),
                ),
                _AttendanceDetailLine(
                  label: AppStrings.scheduledShift,
                  value: shift,
                ),
                _AttendanceDetailLine(
                  label: AppStrings.lateTime,
                  value: '${record.lateMinutes} ${AppStrings.minuteShort}',
                ),
                _AttendanceDetailLine(
                  label: AppStrings.payableHours,
                  value:
                      '${record.payableHours.toStringAsFixed(2)} ${AppStrings.hourShort}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _AttendanceDetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.progressWidth,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _PayRateDialog extends StatefulWidget {
  final StaffPayrollRowDto row;
  final DateTime effectiveFrom;

  const _PayRateDialog({required this.row, required this.effectiveFrom});

  @override
  State<_PayRateDialog> createState() => _PayRateDialogState();
}

class _PayRateDialogState extends State<_PayRateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rateController;
  late DateTime _effectiveFrom;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.row.hourlyRate?.toStringAsFixed(2) ?? '',
    );
    _effectiveFrom = widget.effectiveFrom;
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${AppStrings.setHourlyRate}: ${widget.row.staffName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MoneyField(
              controller: _rateController,
              label: AppStrings.hourlyRate,
              minimum: 0.01,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.effectiveFrom),
              trailing: Text(_date(_effectiveFrom)),
              onTap: _pickEffectiveDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.save)),
      ],
    );
  }

  Future<void> _pickEffectiveDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _effectiveFrom,
      firstDate: DateTime(
        BranchManagerValidationRules.earliestSupportedDateYear,
      ),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (selected != null) setState(() => _effectiveFrom = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      UpdateStaffPayRateRequestDto(
        staffId: widget.row.staffId,
        hourlyRate: double.parse(_rateController.text.trim()),
        effectiveFrom: _effectiveFrom,
      ),
    );
  }
}

class _PayrollDialog extends StatefulWidget {
  final StaffPayrollRowDto row;
  final StaffPayrollSummaryDto payroll;

  const _PayrollDialog({required this.row, required this.payroll});

  @override
  State<_PayrollDialog> createState() => _PayrollDialogState();
}

class _PayrollDialogState extends State<_PayrollDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bonusController;
  late final TextEditingController _deductionController;
  late final TextEditingController _notesController;
  String _status = 'DRAFT';

  @override
  void initState() {
    super.initState();
    _bonusController = TextEditingController(
      text: widget.row.bonus.toStringAsFixed(2),
    );
    _deductionController = TextEditingController(
      text: widget.row.deduction.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: widget.row.notes ?? '');
  }

  @override
  void dispose() {
    _bonusController.dispose();
    _deductionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${AppStrings.calculatePayroll}: ${widget.row.staffName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(AppStrings.recordedWorkHours),
                trailing: Text(widget.row.completedHours.toStringAsFixed(2)),
              ),
              ListTile(
                title: const Text(AppStrings.basePay),
                trailing: Text(_money(widget.row.basePay)),
              ),
              ListTile(
                title: const Text(AppStrings.latePayReduction),
                subtitle: const Text(AppStrings.latePayReductionHelp),
                trailing: Text(_money(widget.row.latePayReduction)),
              ),
              _MoneyField(
                controller: _bonusController,
                label: AppStrings.bonus,
              ),
              _MoneyField(
                controller: _deductionController,
                label: AppStrings.deduction,
              ),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: AppStrings.status),
                items: const [
                  DropdownMenuItem(
                    value: 'DRAFT',
                    child: Text(AppStrings.draft),
                  ),
                  DropdownMenuItem(
                    value: 'CONFIRMED',
                    child: Text(AppStrings.confirmed),
                  ),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              TextFormField(
                controller: _notesController,
                maxLength: BranchManagerValidationRules.maximumShiftNotesLength,
                maxLines: 3,
                decoration: const InputDecoration(labelText: AppStrings.notes),
              ),
              if (_status == 'CONFIRMED')
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    AppStrings.confirmPayrollWarning,
                    style: AppTextStyles.caption,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.save)),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bonus = double.parse(_bonusController.text.trim());
    final deduction = double.parse(_deductionController.text.trim());
    if (deduction > widget.row.basePay + bonus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.deductionTooHigh)),
      );
      return;
    }
    Navigator.pop(
      context,
      UpsertStaffPayrollRequestDto(
        staffId: widget.row.staffId,
        periodStart: widget.payroll.periodStart,
        periodEnd: widget.payroll.periodEnd,
        bonus: bonus,
        deduction: deduction,
        status: _status,
        notes: _notesController.text.trim(),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double minimum;

  const _MoneyField({
    required this.controller,
    required this.label,
    this.minimum = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final input = value?.trim() ?? '';
        if (!BranchManagerValidationRules.decimalPattern.hasMatch(input)) {
          return AppStrings.maximumTwoDecimalPlaces;
        }
        final amount = double.tryParse(input);
        if (amount == null || amount < minimum) return AppStrings.invalidNumber;
        if (amount > BranchManagerValidationRules.maximumCurrencyAmount) {
          return '${AppStrings.maximumValue} ${BranchManagerValidationRules.maximumCurrencyAmount.toStringAsFixed(0)}';
        }
        return null;
      },
    );
  }
}

String _money(double value) =>
    '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

String _time(DateTime value) {
  final localValue = value.toLocal();
  return '${localValue.hour.toString().padLeft(2, '0')}:'
      '${localValue.minute.toString().padLeft(2, '0')}';
}

String _clockValue(String value) {
  final parts = value.split(':');
  return parts.length < 2 ? value : '${parts[0]}:${parts[1]}';
}
