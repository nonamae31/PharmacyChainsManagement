import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
import '../../branch_dashboard/boundary/branch_dashboard_screen.dart';
import '../../branch_dashboard/control/branch_dashboard_bloc.dart';
import '../../branch_dashboard/control/branch_dashboard_event.dart';
import '../../branch_dashboard/control/branch_dashboard_state.dart';
import '../../branch_inventory/boundary/branch_inventory_screen.dart';
import '../../branch_inventory/control/branch_inventory_bloc.dart';
import '../../branch_inventory/control/branch_inventory_event.dart';
import '../../branch_inventory/control/branch_inventory_state.dart';
import '../../branch_revenue/boundary/branch_revenue_screen.dart';
import '../../branch_revenue/control/branch_revenue_bloc.dart';
import '../../branch_revenue/control/branch_revenue_event.dart';
import '../../branch_revenue/control/branch_revenue_state.dart';
import '../../business_admin/boundary/profile_screen.dart';
import '../../staff_performance/boundary/staff_performance_screen.dart';
import '../../staff_performance/control/staff_performance_bloc.dart';
import '../../staff_performance/control/staff_performance_event.dart';
import '../../staff_performance/control/staff_performance_state.dart';

class BranchManagerPortalScreen extends StatefulWidget {
  const BranchManagerPortalScreen({super.key});

  @override
  State<BranchManagerPortalScreen> createState() =>
      _BranchManagerPortalScreenState();
}

class _BranchManagerPortalScreenState extends State<BranchManagerPortalScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    _refreshTab(index);
  }

  void _openProfile() => _onTabSelected(4);

  void _refreshTab(int index) {
    switch (index) {
      case 0:
        final state = context.read<BranchDashboardBloc>().state;
        context.read<BranchDashboardBloc>().add(
          BranchDashboardFetchRequested(
            trendPeriod: state is BranchDashboardLoadSuccess
                ? state.trendPeriod
                : 'month',
          ),
        );
        break;
      case 1:
        final state = context.read<BranchRevenueBloc>().state;
        context.read<BranchRevenueBloc>().add(
          BranchRevenueFetchRequested(
            period: state is BranchRevenueLoadSuccess ? state.period : 'daily',
          ),
        );
        break;
      case 2:
        final state = context.read<StaffPerformanceBloc>().state;
        context.read<StaffPerformanceBloc>().add(
          StaffPerformanceFetchRequested(
            search: state is StaffPerformanceLoadSuccess ? state.search : null,
            status: state is StaffPerformanceLoadSuccess ? state.status : 'all',
            sort: state is StaffPerformanceLoadSuccess
                ? state.sort
                : 'revenue_desc',
            shiftDate: state is StaffPerformanceLoadSuccess
                ? state.shiftDate
                : null,
          ),
        );
        break;
      case 3:
        final state = context.read<BranchInventoryBloc>().state;
        context.read<BranchInventoryBloc>().add(
          BranchInventoryFetchRequested(
            search: state is BranchInventoryLoadSuccess ? state.search : null,
            category: state is BranchInventoryLoadSuccess
                ? state.category
                : null,
            status: state is BranchInventoryLoadSuccess ? state.status : null,
          ),
        );
        break;
    }
  }

  static const _destinations = [
    (AppStrings.dashboard, Icons.dashboard_outlined),
    (AppStrings.revenue, Icons.account_balance_wallet_outlined),
    (AppStrings.staff, Icons.groups_outlined),
    (AppStrings.inventory, Icons.inventory_2_outlined),
    (AppStrings.profile, Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mobile = screenWidth < AppSpacing.mobileHeaderBreakpoint;
    final compact = screenWidth < AppSpacing.compactNavigationBreakpoint;
    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        BranchDashboardScreen(onProfileTap: _openProfile),
        BranchRevenueScreen(onProfileTap: _openProfile),
        StaffPerformanceScreen(onProfileTap: _openProfile),
        BranchInventoryScreen(onProfileTap: _openProfile),
        const ProfileScreen(),
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
          onDestinationSelected: _onTabSelected,
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
      onSelected: _onTabSelected,
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _PortalNavigationHeader(compact: compact),
            const SizedBox(height: AppSpacing.xs),
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
            const Divider(height: AppSpacing.hairline),
            const SizedBox(height: AppSpacing.xs),
            _NavigationItem(
              label: AppStrings.logOut,
              icon: Icons.logout,
              selected: false,
              compact: compact,
              danger: true,
              onTap: onLogout,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _PortalNavigationHeader extends StatelessWidget {
  final bool compact;

  const _PortalNavigationHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: compact
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.local_pharmacy,
              color: AppColors.surface,
              size: AppSpacing.iconMedium,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.appTitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionTitle,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppStrings.appSubtitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Material(
        color: selected ? AppColors.tealSoft : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: AppSpacing.xxl,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: AppSpacing.iconMedium),
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
