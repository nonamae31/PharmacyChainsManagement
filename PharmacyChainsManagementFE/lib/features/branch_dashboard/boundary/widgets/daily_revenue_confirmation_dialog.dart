import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/constants/branch_manager_validation_rules.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../entity/daily_revenue_confirmation_dto.dart';

class DailyRevenueConfirmationDialog extends StatefulWidget {
  final double systemRevenue;

  const DailyRevenueConfirmationDialog({
    super.key,
    required this.systemRevenue,
  });

  @override
  State<DailyRevenueConfirmationDialog> createState() =>
      _DailyRevenueConfirmationDialogState();
}

class _DailyRevenueConfirmationDialogState
    extends State<DailyRevenueConfirmationDialog> {
  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  final _otherController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.confirmDailyRevenue),
      content: SizedBox(
        width: AppSpacing.confirmationDialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.systemRevenue}: ${_currency(widget.systemRevenue)}',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              _AmountField(
                controller: _cashController,
                label: AppStrings.actualCash,
              ),
              const SizedBox(height: AppSpacing.sm),
              _AmountField(
                controller: _bankController,
                label: AppStrings.actualBankTransfer,
              ),
              const SizedBox(height: AppSpacing.sm),
              _AmountField(
                controller: _otherController,
                label: AppStrings.actualOther,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reasonController,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.differenceReason,
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
        FilledButton(onPressed: _submit, child: const Text(AppStrings.confirm)),
      ],
    );
  }

  void _submit() {
    final actualCash = _parseAmount(_cashController.text);
    final actualBankTransfer = _parseAmount(_bankController.text);
    final actualOther = _parseAmount(_otherController.text);
    if (actualCash == null ||
        actualBankTransfer == null ||
        actualOther == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.invalidNumber)));
      return;
    }
    final actualCents = ((actualCash + actualBankTransfer + actualOther) * 100)
        .round();
    final systemCents = (widget.systemRevenue * 100).round();
    if (actualCents != systemCents && _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.differenceReasonRequired)),
      );
      return;
    }
    Navigator.pop(
      context,
      ConfirmDailyRevenueRequestDto(
        actualCash: actualCash,
        actualBankTransfer: actualBankTransfer,
        actualOther: actualOther,
        differenceReason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      ),
    );
  }

  double? _parseAmount(String input) {
    final normalized = input.replaceAll(',', '').trim();
    if (normalized.isEmpty) return 0;
    if (!BranchManagerValidationRules.decimalPattern.hasMatch(normalized)) {
      return null;
    }
    final value = double.tryParse(normalized);
    return value == null ||
            value < 0 ||
            value > BranchManagerValidationRules.maximumCurrencyAmount
        ? null
        : value;
  }

  String _currency(double value) =>
      '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _otherController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _AmountField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: AppStrings.currencySymbol,
      ),
    );
  }
}
