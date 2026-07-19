import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/control/auth_bloc.dart';
import '../../features/auth/control/auth_state.dart';
import '../../features/auth/boundary/login_screen.dart';
import '../../features/founder_admin/presentation/screens/founder_layout_screen.dart';
import '../../features/home/boundary/business_admin_home_screen.dart';
import '../../features/home/boundary/branch_manager_home_screen.dart';
import '../../features/home/boundary/staff_home_screen.dart';
import '../../features/home/boundary/inventory_home_screen.dart';
import '../../features/cash_flow/presentation/screens/cash_flow_screen.dart';
import 'dart:async';

class AppRouter {
  final AuthBloc authBloc;
  
  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isLoggingIn = state.uri.toString() == '/login';
      
      print('AppRouter redirect triggered: isLoggingIn=$isLoggingIn, authState=$authState');

      if (authState is! AuthAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        final role = authState.role.toLowerCase();
        print('AppRouter navigating to home for role: $role');
        switch (role) {
          case 'founder':
            return '/founder_home';
          case 'business_admin':
            return '/business_admin_home';
          case 'branch_manager':
            return '/branch_manager_home';
          case 'staff':
            return '/staff_home';
          case 'inventory_manager':
            return '/inventory_home';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/founder_home',
        pageBuilder: (context, state) => _buildTransition(context, state, const FounderLayoutScreen()),
      ),
      GoRoute(
        path: '/business_admin_home',
        pageBuilder: (context, state) => _buildTransition(context, state, const BusinessAdminHomeScreen()),
      ),
      GoRoute(
        path: '/branch_manager_home',
        pageBuilder: (context, state) => _buildTransition(context, state, const BranchManagerHomeScreen()),
      ),
      GoRoute(
        path: '/staff_home',
        pageBuilder: (context, state) => _buildTransition(context, state, const StaffHomeScreen()),
      ),
      GoRoute(
        path: '/inventory_home',
        pageBuilder: (context, state) => _buildTransition(context, state, const InventoryHomeScreen()),
      ),
      GoRoute(
        path: '/cash_flow',
        pageBuilder: (context, state) => _buildTransition(context, state, const CashFlowScreen()),
      ),
    ],
  );

  CustomTransitionPage _buildTransition(BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
