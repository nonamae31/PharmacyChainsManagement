import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppStatusChip extends StatelessWidget {
  final String label;

  const AppStatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    final isDanger =
        normalized.contains('critical') ||
        normalized.contains('out') ||
        normalized.contains('inactive') ||
        normalized.contains('cancel') ||
        normalized.contains('expired') ||
        normalized.contains('failed');
    final isWarning =
        normalized.contains('low') ||
        normalized.contains('high') ||
        normalized.contains('unpaid') ||
        normalized.contains('pending');
    final foreground = isDanger
        ? AppColors.danger
        : (isWarning ? AppColors.warning : AppColors.success);
    final background = isDanger
        ? AppColors.dangerSoft
        : (isWarning ? AppColors.warningSoft : AppColors.successSoft);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
