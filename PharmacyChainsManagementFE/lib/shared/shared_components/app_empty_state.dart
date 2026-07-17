import 'package:flutter/material.dart';

import '../../core/constants/branch_manager_app_strings.dart';
import '../../core/theme/branch_manager_app_theme.dart';

class AppEmptyState extends StatelessWidget {
  final String message;

  const AppEmptyState({super.key, this.message = AppStrings.noData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, size: AppSpacing.iconLarge, color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
