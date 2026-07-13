import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';

class BusinessAdminHomeScreen extends StatelessWidget {
  const BusinessAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual HomeBloc state
    const bool isLoading = false; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Admin Dashboard'),
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
                title: Text('Monthly Sales'),
                subtitle: Text('\$340,000'),
                leading: Icon(Icons.trending_up),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Employees'),
                subtitle: Text('128'),
                leading: Icon(Icons.people),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
