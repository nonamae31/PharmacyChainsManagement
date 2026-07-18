import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../entity/daily_revenue_confirmation_dto.dart';

class DailyRevenueConfirmationStatusCard extends StatelessWidget {
  final DailyRevenueConfirmationDto? confirmation;
  final VoidCallback onConfirmRevenue;
  final VoidCallback onViewConfirmation;

  const DailyRevenueConfirmationStatusCard({
    super.key,
    required this.confirmation,
    required this.onConfirmRevenue,
    required this.onViewConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final confirmed = confirmation != null;
    return AppSectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            children: [
              Icon(
                confirmed
                    ? Icons.verified_outlined
                    : Icons.pending_actions_outlined,
                color: confirmed ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.dailyRevenueConfirmationStatus,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      confirmed
                          ? AppStrings.dailyRevenueConfirmedMessage
                          : AppStrings.dailyRevenueNotConfirmedMessage,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = confirmed
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppStatusChip(
                      label: AppStrings.dailyRevenueConfirmed,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: onViewConfirmation,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text(AppStrings.viewConfirmation),
                    ),
                  ],
                )
              : FilledButton.icon(
                  onPressed: onConfirmRevenue,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text(AppStrings.confirmDailyRevenue),
                );
          if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: AppSpacing.sm),
                action,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          );
        },
      ),
    );
  }
}
