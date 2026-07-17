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
    final iconBackground = emphasized
        ? AppColors.surface.withValues(alpha: 0.16)
        : accentColor.withValues(alpha: 0.12);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, (1 - progress) * 8),
          child: child,
        ),
      ),
      child: SizedBox(
        height: AppSpacing.metricHeight,
        child: AppSectionCard(
          color: emphasized ? AppColors.primary : AppColors.surface,
          gradient: emphasized ? AppColors.cardGradient : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(
                      icon,
                      size: AppSpacing.iconMedium,
                      color: emphasized ? AppColors.surface : accentColor,
                    ),
                  ),
                  const Spacer(),
                  if (helper != null)
                    Flexible(
                      child: Text(
                        helper!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
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
      ),
    );
  }
}
