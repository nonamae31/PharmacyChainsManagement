import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';

class BranchManagerHomeScreen extends StatelessWidget {
  const BranchManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual HomeBloc state
    const bool isLoading = false; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Manager Dashboard'),
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
                title: Text('Today Sales'),
                subtitle: Text('\$2,450'),
                leading: Icon(Icons.point_of_sale),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Staff on Shift'),
                subtitle: Text('4'),
                leading: Icon(Icons.badge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
