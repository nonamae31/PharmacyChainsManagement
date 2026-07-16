import 'package:flutter/material.dart';

import '../../core/constants/branch_manager_app_strings.dart';
import '../../core/theme/branch_manager_app_theme.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: AppSpacing.xxl, color: AppColors.danger),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text(AppStrings.retry)),
          ],
        ),
      ),
    );
  }
}
