import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
import '../../auth/control/auth_state.dart';
import '../../auth/boundary/login_screen.dart';

class InventoryHomeScreen extends StatelessWidget {
  const InventoryHomeScreen({super.key});

  void _confirmAndLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Xác nhận đăng xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Quản lý kho (Inventory) không?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy bỏ (Cancel)', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              try {
                context.read<AuthBloc>().add(LogoutRequested());
              } catch (_) {}
              try {
                context.go('/login');
              } catch (_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Đăng xuất (Logout)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual HomeBloc state
    const bool isLoading = false; 

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          try {
            context.go('/login');
          } catch (_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Dashboard'),
          actions: [
            IconButton(
              key: const Key('logoutButton'), 
              tooltip: 'Logout', 
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              onPressed: () => _confirmAndLogout(context),
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
      ),
    );
  }
}
