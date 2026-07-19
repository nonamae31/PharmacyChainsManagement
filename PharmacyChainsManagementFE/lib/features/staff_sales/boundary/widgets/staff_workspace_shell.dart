import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/control/auth_bloc.dart';
import '../../../auth/control/auth_event.dart';

enum StaffWorkspaceSection {
  dashboard,
  medicines,
  invoices,
  payments,
}

class StaffWorkspaceShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final StaffWorkspaceSection section;
  final Widget child;
  final List<Widget>? actions;

  const StaffWorkspaceShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.child,
    this.actions,
  });

  static const _desktopBreakpoint = 900.0;
  static const _navItems = [
    (
      StaffWorkspaceSection.dashboard,
      'Dashboard',
      Icons.grid_view_outlined,
      '/staff_home',
    ),
    (
      StaffWorkspaceSection.medicines,
      'Medicine search',
      Icons.medication_outlined,
      '/staff/medicines',
    ),
    (
      StaffWorkspaceSection.invoices,
      'Invoices',
      Icons.receipt_long_outlined,
      '/staff/invoices',
    ),
    (
      StaffWorkspaceSection.payments,
      'Payments',
      Icons.payments_outlined,
      '/staff/payments',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
    final selectedMobileIndex = _navItems.indexWhere(
      (item) => item.$1 == section,
    );
    final content = Column(
      children: [
        _TopBar(actions: actions),
        Expanded(
          child: Container(
            color: const Color(0xFFF7F8FC),
            child: Padding(
              padding: EdgeInsets.all(desktop ? 28 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B3156),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF607083),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (desktop) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(section: section),
            Expanded(child: content),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(child: content),
      bottomNavigationBar: selectedMobileIndex < 0
          ? null
          : NavigationBar(
              selectedIndex: selectedMobileIndex,
              onDestinationSelected: (index) =>
                  context.go(_navItems[index].$4),
              destinations: _navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.$3),
                      label: item.$2,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final List<Widget>? actions;
  const _TopBar({this.actions});

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E7EE))),
    ),
    child: Row(
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search medicines, invoices... ',
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFF7F8FC),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ...(actions ?? const []),
        const IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
        const IconButton(onPressed: null, icon: Icon(Icons.help_outline)),
        const IconButton(onPressed: null, icon: Icon(Icons.settings_outlined)),
        IconButton(
          tooltip: 'Log out',
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
  );
}

class _Sidebar extends StatelessWidget {
  final StaffWorkspaceSection section;
  const _Sidebar({required this.section});

  @override
  Widget build(BuildContext context) => Container(
    width: 248,
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stratos Enterprise',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3156),
                ),
              ),
              SizedBox(height: 4),
              Text('Pharmacy Branch 042'),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => context.go('/staff/invoices/new'),
          icon: const Icon(Icons.add),
          label: const Text('New invoice'),
        ),
        const SizedBox(height: 24),
        ...StaffWorkspaceShell._navItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              selected: item.$1 == section,
              selectedTileColor: const Color(0xFFDCEBFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              leading: Icon(item.$3),
              title: Text(item.$2),
              onTap: () => context.go(item.$4),
            ),
          ),
        ),
        const Spacer(),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Color(0xFFB42318)),
          title: const Text(
            'Log out',
            style: TextStyle(color: Color(0xFFB42318)),
          ),
          onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
      ],
    ),
  );
}
