import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual HomeBloc state
    const bool isLoading = false; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
                title: Text('New Prescriptions'),
                subtitle: Text('12 pending'),
                leading: Icon(Icons.receipt),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('My Shifts'),
                subtitle: Text('08:00 AM - 04:00 PM'),
                leading: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
