import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
import 'branch_management_screen.dart';
import 'business_analysis_report_screen.dart';
import 'medicine_statistics_screen.dart';
import 'profile_screen.dart';

class BusinessAdminShellScreen extends StatefulWidget {
  const BusinessAdminShellScreen({super.key});

  @override
  State<BusinessAdminShellScreen> createState() =>
      _BusinessAdminShellScreenState();
}

class _BusinessAdminShellScreenState extends State<BusinessAdminShellScreen> {
  static const _desktopBreakpoint = 900.0;
  int _selectedIndex = 0;

  static const _items = [
    _BusinessAdminNavItem(
      label: AppStrings.profile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      screen: ProfileScreen(),
    ),
    _BusinessAdminNavItem(
      label: AppStrings.branchManagement,
      icon: Icons.store_outlined,
      selectedIcon: Icons.store,
      screen: BranchManagementScreen(),
    ),
    _BusinessAdminNavItem(
      label: AppStrings.medicineStatistics,
      icon: Icons.medication_outlined,
      selectedIcon: Icons.medication,
      screen: MedicineStatisticsScreen(),
    ),
    _BusinessAdminNavItem(
      label: AppStrings.businessAnalysisReport,
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      screen: BusinessAnalysisReportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= _desktopBreakpoint;
        final body = KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _items[_selectedIndex].screen,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.businessAdminDashboard),
            actions: [
              IconButton(
                tooltip: AppStrings.logout,
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    context.read<AuthBloc>().add(LogoutRequested()),
              ),
            ],
          ),
          body: useRail
              ? Row(
                  children: [
                    _BusinessAdminNavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) =>
                          setState(() => _selectedIndex = index),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: body,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: body,
                ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  destinations: _items
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class _BusinessAdminNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _BusinessAdminNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: true,
      minExtendedWidth: 220,
      backgroundColor: AppColors.surface,
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        child: Text(
          'Stratos Health',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF0B2F5B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: TextButton.icon(
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logout),
            ),
          ),
        ),
      ),
      destinations: _BusinessAdminShellScreenState._items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }
}

class _BusinessAdminNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  const _BusinessAdminNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
