import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: AppSpacing.xl,
        height: AppSpacing.xl,
        child: CircularProgressIndicator(strokeWidth: AppSpacing.xxs),
      ),
    );
  }
}
