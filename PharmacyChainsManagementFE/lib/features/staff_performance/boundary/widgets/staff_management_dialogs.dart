import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/constants/branch_manager_validation_rules.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../entity/staff_management_dto.dart';
import '../../entity/staff_performance_dto.dart';

class StaffFilterSelection {
  final String status;
  final String sort;

  const StaffFilterSelection({required this.status, required this.sort});
}

class CreateStaffDialog extends StatefulWidget {
  const CreateStaffDialog({super.key});

  @override
  State<CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<CreateStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addStaff),
      content: SizedBox(
        width: AppSpacing.dialogWidthStandard,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: BranchManagerValidationRules.maximumFullNameLength,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                  ),
                  validator: (value) =>
                      value == null ||
                          value.trim().length <
                              BranchManagerValidationRules.minimumFullNameLength
                      ? AppStrings.requiredField
                      : null,
                ),
                TextFormField(
                  controller: _emailController,
                  maxLength: BranchManagerValidationRules.maximumEmailLength,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return BranchManagerValidationRules.emailPattern.hasMatch(
                          email,
                        )
                        ? null
                        : AppStrings.invalidEmail;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  maxLength: BranchManagerValidationRules.maximumPhoneLength,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: AppStrings.phone,
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return null;
                    return BranchManagerValidationRules.phonePattern.hasMatch(
                          phone,
                        )
                        ? null
                        : AppStrings.invalidPhone;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  maxLength: BranchManagerValidationRules.maximumPasswordLength,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.temporaryPassword,
                  ),
                  validator: (value) =>
                      BranchManagerValidationRules.strongPasswordPattern
                          .hasMatch(value ?? '')
                      ? null
                      : AppStrings.passwordStrength,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.create)),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      CreateBranchStaffRequestDto(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}

class StaffFilterDialog extends StatefulWidget {
  final String initialStatus;
  final String initialSort;

  const StaffFilterDialog({
    super.key,
    required this.initialStatus,
    required this.initialSort,
  });

  @override
  State<StaffFilterDialog> createState() => _StaffFilterDialogState();
}

class _StaffFilterDialogState extends State<StaffFilterDialog> {
  late String _status = widget.initialStatus;
  late String _sort = widget.initialSort;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.filterStaff),
      content: SizedBox(
        width: AppSpacing.dialogWidthCompact,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: AppStrings.status),
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text(AppStrings.allStatuses),
                ),
                DropdownMenuItem(
                  value: 'ACTIVE',
                  child: Text(AppStrings.active),
                ),
                DropdownMenuItem(
                  value: 'INACTIVE',
                  child: Text(AppStrings.inactive),
                ),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'all'),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _sort,
              decoration: const InputDecoration(labelText: AppStrings.sortBy),
              items: const [
                DropdownMenuItem(
                  value: 'revenue_desc',
                  child: Text(AppStrings.highestRevenue),
                ),
                DropdownMenuItem(
                  value: 'performance_desc',
                  child: Text(AppStrings.highestPerformance),
                ),
                DropdownMenuItem(
                  value: 'name_asc',
                  child: Text(AppStrings.nameAscending),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _sort = value ?? 'revenue_desc'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            StaffFilterSelection(status: _status, sort: _sort),
          ),
          child: const Text(AppStrings.apply),
        ),
      ],
    );
  }
}

class StaffAssessmentDialog extends StatefulWidget {
  final List<StaffPerformanceRowDto> staff;

  const StaffAssessmentDialog({super.key, required this.staff});

  @override
  State<StaffAssessmentDialog> createState() => _StaffAssessmentDialogState();
}

class _StaffAssessmentDialogState extends State<StaffAssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _ratingController = TextEditingController();
  final _attendanceController = TextEditingController();
  final _scoreController = TextEditingController();
  final _notesController = TextEditingController();
  late String _staffId = widget.staff.first.staffId;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _targetController.dispose();
    _ratingController.dispose();
    _attendanceController.dispose();
    _scoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.newAssessment),
      content: SizedBox(
        width: AppSpacing.dialogWidthWide,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _AssessmentFormFields(
              staff: widget.staff,
              staffId: _staffId,
              onStaffChanged: (value) => setState(() => _staffId = value),
              date: _date,
              onDateChanged: (value) => setState(() => _date = value),
              targetController: _targetController,
              ratingController: _ratingController,
              attendanceController: _attendanceController,
              scoreController: _scoreController,
              notesController: _notesController,
            ),
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
    Navigator.pop(
      context,
      CreateStaffAssessmentRequestDto(
        staffId: _staffId,
        assessmentDate: _date,
        salesTarget: double.parse(_targetController.text),
        customerRating: double.parse(_ratingController.text),
        attendancePercent: double.parse(_attendanceController.text),
        performanceScore: double.parse(_scoreController.text),
        notes: _notesController.text.trim(),
      ),
    );
  }
}

class StaffShiftDialog extends StatefulWidget {
  final List<StaffPerformanceRowDto> staff;

  const StaffShiftDialog({super.key, required this.staff});

  @override
  State<StaffShiftDialog> createState() => _StaffShiftDialogState();
}

class _StaffShiftDialogState extends State<StaffShiftDialog> {
  final _notesController = TextEditingController();
  late String _staffId = widget.staff.first.staffId;
  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 12, minute: 0);
  String _shiftPreset = 'MORNING';
  String _status = 'SCHEDULED';
  bool _applyToWeeklySchedule = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.updateShiftRoster),
      content: SizedBox(
        width: AppSpacing.dialogWidthStandard,
        child: SingleChildScrollView(
          child: _ShiftFormFields(
            staff: widget.staff,
            staffId: _staffId,
            onStaffChanged: (value) => setState(() => _staffId = value),
            date: _date,
            onDateChanged: (value) => setState(() => _date = value),
            shiftPreset: _shiftPreset,
            onShiftPresetChanged: _applyShiftPreset,
            start: _start,
            end: _end,
            onPickStart: () => _pickTime(true),
            onPickEnd: () => _pickTime(false),
            status: _status,
            onStatusChanged: (value) => setState(() {
              _status = value;
              if (value != 'SCHEDULED') _applyToWeeklySchedule = false;
            }),
            applyToWeeklySchedule: _applyToWeeklySchedule,
            onApplyToWeeklyScheduleChanged: (value) => setState(
              () => _applyToWeeklySchedule = value,
            ),
            notesController: _notesController,
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

  Future<void> _pickTime(bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (value == null) return;
    setState(() {
      _shiftPreset = 'CUSTOM';
      start ? _start = value : _end = value;
    });
  }

  void _applyShiftPreset(String value) {
    setState(() {
      _shiftPreset = value;
      switch (value) {
        case 'MORNING':
          _start = const TimeOfDay(hour: 8, minute: 0);
          _end = const TimeOfDay(hour: 12, minute: 0);
          break;
        case 'AFTERNOON':
          _start = const TimeOfDay(hour: 12, minute: 0);
          _end = const TimeOfDay(hour: 17, minute: 0);
          break;
        case 'EVENING':
          _start = const TimeOfDay(hour: 17, minute: 0);
          _end = const TimeOfDay(hour: 22, minute: 0);
          break;
      }
    });
  }

  void _submit() {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (_status == 'SCHEDULED' && _date.weekday == DateTime.sunday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.sundayDayOffHelp)),
      );
      return;
    }
    if (_status == 'SCHEDULED' && startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.invalidShiftTime)),
      );
      return;
    }
    if (_status == 'SCHEDULED' &&
        endMinutes - startMinutes >
            BranchManagerValidationRules.maximumShiftHours * 60) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.shiftTooLong)));
      return;
    }
    Navigator.pop(
      context,
      UpsertStaffShiftRequestDto(
        staffId: _staffId,
        shiftDate: _date,
        startTime: TimeOfDayValue(_start.hour, _start.minute),
        endTime: TimeOfDayValue(_end.hour, _end.minute),
        status: _status,
        notes: _notesController.text.trim(),
        applyToWeeklySchedule: _applyToWeeklySchedule,
      ),
    );
  }
}

class _StaffMemberDropdown extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final String staffId;
  final ValueChanged<String> onChanged;

  const _StaffMemberDropdown({
    required this.staff,
    required this.staffId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: staffId,
      decoration: const InputDecoration(labelText: AppStrings.staffMember),
      items: staff
          .map(
            (item) => DropdownMenuItem(
              value: item.staffId,
              child: Text(item.fullName),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => onChanged(value!),
    );
  }
}

class _AssessmentFormFields extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final String staffId;
  final ValueChanged<String> onStaffChanged;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController targetController;
  final TextEditingController ratingController;
  final TextEditingController attendanceController;
  final TextEditingController scoreController;
  final TextEditingController notesController;

  const _AssessmentFormFields({
    required this.staff,
    required this.staffId,
    required this.onStaffChanged,
    required this.date,
    required this.onDateChanged,
    required this.targetController,
    required this.ratingController,
    required this.attendanceController,
    required this.scoreController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StaffMemberDropdown(
          staff: staff,
          staffId: staffId,
          onChanged: onStaffChanged,
        ),
        _DateField(
          label: AppStrings.assessmentDate,
          value: date,
          firstDate: today,
          lastDate: today,
          onChanged: onDateChanged,
        ),
        _NumberField(
          controller: targetController,
          label: AppStrings.salesTarget,
          minimum: 0,
          maximum: BranchManagerValidationRules.maximumCurrencyAmount,
        ),
        _NumberField(
          controller: ratingController,
          label: AppStrings.customerRating,
          minimum: 0,
          maximum: 5,
        ),
        _NumberField(
          controller: attendanceController,
          label: AppStrings.attendance,
          minimum: 0,
          maximum: 100,
        ),
        _NumberField(
          controller: scoreController,
          label: AppStrings.performanceScore,
          minimum: 0,
          maximum: 100,
        ),
        TextFormField(
          controller: notesController,
          maxLength: BranchManagerValidationRules.maximumAssessmentNotesLength,
          maxLines: 3,
          decoration: const InputDecoration(labelText: AppStrings.notes),
        ),
      ],
    );
  }
}

class _ShiftFormFields extends StatelessWidget {
  final List<StaffPerformanceRowDto> staff;
  final String staffId;
  final ValueChanged<String> onStaffChanged;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final String shiftPreset;
  final ValueChanged<String> onShiftPresetChanged;
  final TimeOfDay start;
  final TimeOfDay end;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final bool applyToWeeklySchedule;
  final ValueChanged<bool> onApplyToWeeklyScheduleChanged;
  final TextEditingController notesController;

  const _ShiftFormFields({
    required this.staff,
    required this.staffId,
    required this.onStaffChanged,
    required this.date,
    required this.onDateChanged,
    required this.shiftPreset,
    required this.onShiftPresetChanged,
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
    required this.status,
    required this.onStatusChanged,
    required this.applyToWeeklySchedule,
    required this.onApplyToWeeklyScheduleChanged,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StaffMemberDropdown(
          staff: staff,
          staffId: staffId,
          onChanged: onStaffChanged,
        ),
        _DateField(
          label: AppStrings.shiftDate,
          value: date,
          firstDate: DateTime(
            BranchManagerValidationRules.earliestSupportedDateYear,
          ),
          lastDate: DateTime(
            today.year + BranchManagerValidationRules.maximumSchedulingYears,
            today.month,
            today.day,
          ),
          onChanged: onDateChanged,
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(shiftPreset),
          initialValue: shiftPreset,
          decoration: const InputDecoration(labelText: AppStrings.shiftPreset),
          items: const [
            DropdownMenuItem(
              value: 'MORNING',
              child: Text(AppStrings.morningShift),
            ),
            DropdownMenuItem(
              value: 'AFTERNOON',
              child: Text(AppStrings.afternoonShift),
            ),
            DropdownMenuItem(
              value: 'EVENING',
              child: Text(AppStrings.eveningShift),
            ),
            DropdownMenuItem(
              value: 'CUSTOM',
              child: Text(AppStrings.customShift),
            ),
          ],
          onChanged: status == 'SCHEDULED'
              ? (value) => onShiftPresetChanged(value!)
              : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(AppStrings.startTime),
          trailing: Text(start.format(context)),
          onTap: status == 'SCHEDULED' ? onPickStart : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(AppStrings.endTime),
          trailing: Text(end.format(context)),
          onTap: status == 'SCHEDULED' ? onPickEnd : null,
        ),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: AppStrings.status),
          items: const [
            DropdownMenuItem(
              value: 'SCHEDULED',
              child: Text(AppStrings.scheduled),
            ),
            DropdownMenuItem(value: 'OFF', child: Text(AppStrings.dayOff)),
            DropdownMenuItem(
              value: 'CANCELLED',
              child: Text(AppStrings.cancelled),
            ),
          ],
          onChanged: (value) => onStatusChanged(value!),
        ),
        if (status != 'SCHEDULED')
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              AppStrings.inactiveShiftTimeHelp,
              style: AppTextStyles.caption,
            ),
          ),
        if (status == 'SCHEDULED') ...[
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: applyToWeeklySchedule,
            onChanged: (value) =>
                onApplyToWeeklyScheduleChanged(value ?? false),
            title: const Text(AppStrings.applyToWeeklySchedule),
            subtitle: const Text(AppStrings.weeklyScheduleHelp),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        TextField(
          controller: notesController,
          maxLength: BranchManagerValidationRules.maximumShiftNotesLength,
          maxLines: 3,
          decoration: const InputDecoration(labelText: AppStrings.notes),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      ),
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double minimum;
  final double? maximum;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.minimum,
    this.maximum,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final input = value?.trim() ?? '';
        if (input.isEmpty) return AppStrings.invalidNumber;
        if (!BranchManagerValidationRules.decimalPattern.hasMatch(input)) {
          return AppStrings.maximumTwoDecimalPlaces;
        }
        final parsed = double.tryParse(input);
        if (parsed == null || parsed < minimum) return AppStrings.invalidNumber;
        if (maximum != null && parsed > maximum!) {
          return '${AppStrings.maximumValue} ${maximum!.toStringAsFixed(0)}';
        }
        return null;
      },
    );
  }
}
