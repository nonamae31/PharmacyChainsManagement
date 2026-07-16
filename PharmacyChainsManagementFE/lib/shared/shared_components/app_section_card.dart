import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: const [
          BoxShadow(color: AppColors.overlay, blurRadius: AppSpacing.sm, offset: Offset(0, AppSpacing.xxs)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
