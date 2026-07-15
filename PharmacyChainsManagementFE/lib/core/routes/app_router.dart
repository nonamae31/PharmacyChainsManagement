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
import 'dart:async';

class AppRouter {
  final AuthBloc authBloc;
  
  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState is! AuthAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      final role = authState.role.toUpperCase();
      
      String targetPath = '/login';
      switch (role) {
        case 'FOUNDER':
          targetPath = '/founder_home';
          break;
        case 'BUSINESS_ADMIN':
          targetPath = '/business_admin_home';
          break;
        case 'BRANCH_MANAGER':
          targetPath = '/branch_manager_home';
          break;
        case 'STAFF':
          targetPath = '/staff_home';
          break;
        case 'INVENTORY_MANAGER':
          targetPath = '/inventory_home';
          break;
      }

      if (isLoggingIn || state.matchedLocation != targetPath) {
        return targetPath;
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
    _subscription = stream.asBroadcastStream().listen(
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
