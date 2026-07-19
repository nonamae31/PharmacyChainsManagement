import 'package:flutter/material.dart';

import '../../business_admin/boundary/profile_screen.dart';
import 'widgets/staff_workspace_shell.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffWorkspaceShell(
      title: 'Profile',
      subtitle: 'Manage your personal information and account password.',
      section: StaffWorkspaceSection.profile,
      child: ProfileScreen(),
    );
  }
}
