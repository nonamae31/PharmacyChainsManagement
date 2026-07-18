import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../entity/daily_revenue_confirmation_dto.dart';

class DailyRevenueConfirmationDetailsDialog extends StatelessWidget {
  final DailyRevenueConfirmationDto confirmation;

  const DailyRevenueConfirmationDetailsDialog({
    super.key,
    required this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final confirmedAt = confirmation.confirmedAt.toLocal();
    final reason = confirmation.differenceReason?.trim();
    return AlertDialog(
      title: const Text(AppStrings.confirmationDetails),
      content: SizedBox(
        width: AppSpacing.confirmationDialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                label: AppStrings.revenueDate,
                value: localizations.formatFullDate(confirmation.revenueDate),
              ),
              _DetailRow(
                label: AppStrings.confirmedAt,
                value:
                    '${localizations.formatFullDate(confirmedAt)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(confirmedAt))}',
              ),
              _DetailRow(
                label: AppStrings.systemAmount,
                value: _currency(confirmation.systemAmount),
              ),
              _DetailRow(
                label: AppStrings.actualCash,
                value: _currency(confirmation.actualCash),
              ),
              _DetailRow(
                label: AppStrings.actualBankTransfer,
                value: _currency(confirmation.actualBankTransfer),
              ),
              _DetailRow(
                label: AppStrings.actualOther,
                value: _currency(confirmation.actualOther),
              ),
              _DetailRow(
                label: AppStrings.actualAmount,
                value: _currency(confirmation.actualAmount),
              ),
              _DetailRow(
                label: AppStrings.difference,
                value: _currency(confirmation.difference),
                valueColor: confirmation.isMatched
                    ? AppColors.success
                    : AppColors.danger,
              ),
              _DetailRow(
                label: AppStrings.status,
                value: confirmation.isMatched
                    ? AppStrings.matched
                    : AppStrings.differenceFound,
                valueColor: confirmation.isMatched
                    ? AppColors.success
                    : AppColors.danger,
              ),
              if (reason != null && reason.isNotEmpty)
                _DetailRow(label: AppStrings.differenceReason, value: reason),
            ],
          ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _currency(double value) =>
    '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';
