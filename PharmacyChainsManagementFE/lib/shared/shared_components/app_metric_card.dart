import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';
import 'app_section_card.dart';

class AppMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final IconData icon;
  final Color accentColor;
  final bool emphasized;

  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.helper,
    this.accentColor = AppColors.teal,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = emphasized ? AppColors.surface : AppColors.textPrimary;
    return SizedBox(
      height: AppSpacing.metricHeight,
      child: AppSectionCard(
        color: emphasized ? AppColors.primary : AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSpacing.iconMedium, color: emphasized ? AppColors.surface : accentColor),
                const Spacer(),
                if (helper != null)
                  Flexible(
                    child: Text(
                      helper!,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(color: emphasized ? AppColors.tealSoft : accentColor),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(label, style: AppTextStyles.metricLabel.copyWith(color: emphasized ? AppColors.tealSoft : AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.metricValue.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
