import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.onSearchChanged,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = SizedBox(
          width: constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
              ? constraints.maxWidth
              : AppSpacing.searchWidth,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search, size: AppSpacing.iconMedium),
            ),
          ),
        );
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        );
        if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: AppSpacing.md),
              search,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _MobileActionsLayout(actions: actions),
              ],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            search,
            if (actions.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              ...actions,
            ],
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.notifications_none,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            const CircleAvatar(
              radius: AppSpacing.md,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person_outline,
                color: AppColors.surface,
                size: AppSpacing.iconSmall,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MobileActionsLayout extends StatelessWidget {
  final List<Widget> actions;

  const _MobileActionsLayout({required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) {
      return SizedBox(width: double.infinity, child: actions.single);
    }
    final secondaryActions = actions.sublist(0, actions.length - 1);
    final primaryAction = actions.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < secondaryActions.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(child: secondaryActions[index]),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        primaryAction,
      ],
    );
  }
}
