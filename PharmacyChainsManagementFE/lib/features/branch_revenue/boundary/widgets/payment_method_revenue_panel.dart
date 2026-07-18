import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_responsive_metric_grid.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../entity/branch_revenue_dto.dart';

class PaymentMethodRevenuePanel extends StatelessWidget {
  final List<PaymentMethodRevenueDto> paymentMethods;

  const PaymentMethodRevenuePanel({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.revenueByPaymentMethod,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            AppStrings.revenueByPaymentMethodSubtitle,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          if (paymentMethods.isEmpty)
            const AppEmptyState(message: AppStrings.noPaymentMethodRevenue)
          else
            AppResponsiveMetricGrid(
              children: paymentMethods
                  .map(
                    (item) => AppMetricCard(
                      label: _formatPaymentMethod(item.paymentMethod),
                      value:
                          '${AppStrings.currencySymbol}${item.revenue.toStringAsFixed(2)}',
                      helper:
                          '${item.contributionPercent.toStringAsFixed(1)}${AppStrings.percentSymbol}',
                      icon: _paymentMethodIcon(item.paymentMethod),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

String _formatPaymentMethod(String value) {
  final words = value
      .trim()
      .split(RegExp(r'[_\s-]+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .toList(growable: false);
  return words.isEmpty ? AppStrings.otherPaymentMethod : words.join(' ');
}

IconData _paymentMethodIcon(String value) {
  final normalized = value.toUpperCase();
  if (normalized.contains('CASH')) return Icons.payments_outlined;
  if (normalized.contains('BANK') || normalized.contains('TRANSFER')) {
    return Icons.account_balance_outlined;
  }
  if (normalized.contains('CARD')) return Icons.credit_card_outlined;
  return Icons.account_balance_wallet_outlined;
}
