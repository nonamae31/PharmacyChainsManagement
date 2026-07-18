import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppResponsiveMetricGrid extends StatelessWidget {
  final List<Widget> children;

  const AppResponsiveMetricGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppSpacing.fourColumnBreakpoint
            ? 4
            : constraints.maxWidth < AppSpacing.narrowMobileBreakpoint
            ? 1
            : 2;
        final gap = constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
            ? AppSpacing.sm
            : AppSpacing.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}
