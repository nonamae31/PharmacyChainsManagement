import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';

class InventoryHomeScreen extends StatelessWidget {
  const InventoryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual HomeBloc state
    const bool isLoading = false; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        actions: [
          IconButton(key: const Key('logoutButton'), tooltip: 'Logout', 
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Skeletonizer(
        key: const Key('skeleton_loader'),
        enabled: isLoading,
        child: ListView(
          key: const Key('home_dashboard'),
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text('Low Stock Alerts'),
                subtitle: Text('8 items require restocking'),
                leading: Icon(Icons.warning, color: Colors.red),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Total Drugs'),
                subtitle: Text('1,450 SKUs'),
                leading: Icon(Icons.medication),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
