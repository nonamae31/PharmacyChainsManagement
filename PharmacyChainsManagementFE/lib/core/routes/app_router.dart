import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/boundary/login_screen.dart';
import '../../features/auth/control/auth_bloc.dart';
import '../../features/auth/control/auth_state.dart';
import '../../features/branch_portal/boundary/branch_manager_portal_screen.dart';
import '../../features/business_admin/boundary/business_admin_shell_screen.dart';
import '../../features/cash_flow/presentation/screens/cash_flow_screen.dart';
import '../../features/founder_admin/presentation/screens/founder_layout_screen.dart';
import '../../features/inventory/boundary/inventory_dashboard_screen.dart';
import '../../features/prescription/boundary/prescription_detail_screen.dart';
import '../../features/prescription/boundary/prescription_list_screen.dart';
import '../../features/staff_sales/boundary/staff_sales_screens.dart';
import '../../features/staff_sales/entity/staff_sales_dto.dart';
import '../theme/branch_manager_app_theme.dart';

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

      if (isLoggingIn) {
        return null;
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

      if (state.matchedLocation != targetPath) {
        return targetPath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/founder_home',
        pageBuilder: (context, state) =>
            _buildTransition(context, state, const FounderLayoutScreen()),
      ),
      GoRoute(
        path: '/business_admin_home',
        pageBuilder: (context, state) =>
            _buildTransition(context, state, const BusinessAdminShellScreen()),
      ),
      GoRoute(
        path: '/branch_manager_home',
        pageBuilder: (context, state) => _buildTransition(
          context,
          state,
          Theme(
            data: BranchManagerAppTheme.light,
            child: const BranchManagerPortalScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/staff_home',
        pageBuilder: (context, state) =>
            _buildTransition(context, state, const StaffDashboardScreen()),
      ),
      GoRoute(
        path: '/staff/medicines',
        builder: (_, __) => const MedicineSearchScreen(),
      ),
      GoRoute(
        path: '/staff/invoices/new',
        builder: (_, state) =>
            InvoiceGenerationScreen(medicine: state.extra as MedicineDto?),
      ),
      GoRoute(
        path: '/staff/invoices',
        builder: (_, __) => const InvoiceHistoryScreen(),
      ),
      GoRoute(
        path: '/staff/prescriptions',
        builder: (_, __) => const PrescriptionListScreen(),
      ),
      GoRoute(
        path: '/staff/prescriptions/:prescriptionId',
        builder: (_, state) => PrescriptionDetailScreen(
          prescriptionId: state.pathParameters['prescriptionId']!,
        ),
      ),
      GoRoute(
        path: '/staff/payments',
        builder: (_, __) => const PaymentTransactionsScreen(),
      ),
      GoRoute(
        path: '/staff/payments/process',
        builder: (_, state) =>
            PaymentProcessingScreen(invoice: state.extra as InvoiceSummaryDto),
      ),
      GoRoute(
        path: '/inventory_home',
        pageBuilder: (context, state) => _buildTransition(
          context,
          state,
          const InventoryDashboardScreen(branchId: 'BR-001'),
        ),
      ),
      GoRoute(
        path: '/cash_flow',
        pageBuilder: (context, state) =>
            _buildTransition(context, state, const CashFlowScreen()),
      ),
    ],
  );

  CustomTransitionPage _buildTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
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
