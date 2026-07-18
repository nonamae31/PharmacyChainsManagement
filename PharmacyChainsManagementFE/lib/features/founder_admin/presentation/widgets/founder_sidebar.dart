import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/control/auth_bloc.dart';
import '../../../auth/control/auth_event.dart';

class FounderSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const FounderSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  Future<void> _handleLogout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Icon(Icons.admin_panel_settings, size: 48, color: Colors.teal),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Semantics(
              button: true,
              label: 'Logout',
              child: InkWell(
                onTap: () => _handleLogout(context),
                borderRadius: BorderRadius.circular(8),
                hoverColor: Colors.red.shade100,
                child: Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade400),
                      const SizedBox(height: 8),
                      Text('Logout', style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Admins'),
        ),
      ],
    );
  }
}
