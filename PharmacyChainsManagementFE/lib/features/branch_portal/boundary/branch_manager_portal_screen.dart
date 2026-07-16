import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
import '../../branch_dashboard/boundary/branch_dashboard_screen.dart';
import '../../branch_inventory/boundary/branch_inventory_screen.dart';
import '../../branch_revenue/boundary/branch_revenue_screen.dart';
import '../../staff_performance/boundary/staff_performance_screen.dart';

class BranchManagerPortalScreen extends StatefulWidget {
  const BranchManagerPortalScreen({super.key});

  @override
  State<BranchManagerPortalScreen> createState() =>
      _BranchManagerPortalScreenState();
}

class _BranchManagerPortalScreenState extends State<BranchManagerPortalScreen> {
  int _selectedIndex = 0;

  static const _destinations = [
    (AppStrings.dashboard, Icons.dashboard_outlined),
    (AppStrings.revenue, Icons.account_balance_wallet_outlined),
    (AppStrings.staff, Icons.groups_outlined),
    (AppStrings.inventory, Icons.inventory_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mobile = screenWidth < AppSpacing.mobileHeaderBreakpoint;
    final compact = screenWidth < AppSpacing.compactNavigationBreakpoint;
    final content = IndexedStack(
      index: _selectedIndex,
      children: const [
        BranchDashboardScreen(),
        BranchRevenueScreen(),
        StaffPerformanceScreen(),
        BranchInventoryScreen(),
      ],
    );
    if (mobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.local_pharmacy, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(AppStrings.appTitle, style: AppTextStyles.sectionTitle),
            ],
          ),
          actions: [
            IconButton(
              tooltip: AppStrings.logOut,
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              icon: const Icon(Icons.logout, color: AppColors.danger),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: [
            for (final destination in _destinations)
              NavigationDestination(
                icon: Icon(destination.$2),
                selectedIcon: Icon(destination.$2, color: AppColors.primary),
                label: destination.$1,
              ),
          ],
        ),
      );
    }
    final navigation = _PortalNavigation(
      selectedIndex: _selectedIndex,
      compact: compact,
      onSelected: (index) => setState(() => _selectedIndex = index),
      onLogout: () => context.read<AuthBloc>().add(LogoutRequested()),
    );
    return Scaffold(
      body: Row(
        children: [
          navigation,
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _PortalNavigation extends StatelessWidget {
  final int selectedIndex;
  final bool compact;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _PortalNavigation({
    required this.selectedIndex,
    required this.compact,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? AppSpacing.headerHeight : AppSpacing.navWidth,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: compact
                  ? const Icon(Icons.local_pharmacy, color: AppColors.primary)
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appTitle,
                          style: AppTextStyles.sectionTitle,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          AppStrings.appSubtitle,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
            ),
            const Divider(height: AppSpacing.hairline),
            const SizedBox(height: AppSpacing.sm),
            for (
              var index = 0;
              index < _BranchManagerPortalScreenState._destinations.length;
              index++
            )
              _NavigationItem(
                label: _BranchManagerPortalScreenState._destinations[index].$1,
                icon: _BranchManagerPortalScreenState._destinations[index].$2,
                selected: selectedIndex == index,
                compact: compact,
                onTap: () => onSelected(index),
              ),
            const Spacer(),
            _NavigationItem(
              label: AppStrings.logOut,
              icon: Icons.logout,
              selected: false,
              compact: compact,
              danger: true,
              onTap: onLogout,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final bool danger;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.danger
        : (selected ? AppColors.primary : AppColors.textSecondary);
    return Material(
      color: selected ? AppColors.overlay : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: AppSpacing.xxl,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.primary : AppColors.transparent,
                width: AppSpacing.xxs,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSpacing.iconMedium),
              if (!compact) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
