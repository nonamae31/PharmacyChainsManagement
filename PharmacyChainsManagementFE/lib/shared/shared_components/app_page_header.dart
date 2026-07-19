import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/branch_manager_app_theme.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onProfileTap;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.searchHint,
    this.onSearchChanged,
    this.onProfileTap,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = searchHint == null || onSearchChanged == null
            ? null
            : TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: AppSpacing.iconMedium,
                  ),
                ),
              );
        final mobile = constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint;
        final search = searchField == null
            ? null
            : mobile
            ? SizedBox(width: constraints.maxWidth, child: searchField)
            : Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.searchWidth,
                  ),
                  child: searchField,
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
        if (mobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              if (search != null) ...[
                const SizedBox(height: AppSpacing.md),
                search,
              ],
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
            ?search,
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
            Tooltip(
              message: AppStrings.profile,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onProfileTap,
                  customBorder: const CircleBorder(),
                  child: const CircleAvatar(
                    radius: AppSpacing.md,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.surface,
                      size: AppSpacing.iconSmall,
                    ),
                  ),
                ),
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
