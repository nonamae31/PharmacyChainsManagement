import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';

import 'core/constants/branch_manager_app_strings.dart';
import 'core/network/branch_manager_api_client_base.dart';
import 'core/theme/branch_manager_app_theme.dart';
import 'features/auth/boundary/login_screen.dart';
import 'features/auth/control/auth_bloc.dart';
import 'features/auth/control/auth_state.dart';
import 'features/auth/network/auth_api_client.dart';
import 'features/branch_dashboard/control/branch_dashboard_bloc.dart';
import 'features/branch_dashboard/network/branch_dashboard_api_client.dart';
import 'features/branch_inventory/control/branch_inventory_bloc.dart';
import 'features/branch_inventory/network/branch_inventory_api_client.dart';
import 'features/branch_portal/boundary/branch_manager_portal_screen.dart';
import 'features/branch_revenue/control/branch_revenue_bloc.dart';
import 'features/branch_revenue/network/branch_revenue_api_client.dart';
import 'features/staff_performance/control/staff_performance_bloc.dart';
import 'features/staff_performance/network/staff_performance_api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final authBloc = AuthBloc(authApiClient: AuthApiClient(), localAuth: LocalAuthentication());
  final apiClient = BranchManagerApiClientBase();
  runApp(BranchManagerApp(authBloc: authBloc, apiClient: apiClient));
}

class BranchManagerApp extends StatelessWidget {
  final AuthBloc authBloc;
  final BranchManagerApiClientBase apiClient;

  const BranchManagerApp({super.key, required this.authBloc, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider(create: (_) => BranchDashboardBloc(BranchDashboardApiClient(apiClient))),
        BlocProvider(create: (_) => BranchRevenueBloc(BranchRevenueApiClient(apiClient))),
        BlocProvider(create: (_) => StaffPerformanceBloc(StaffPerformanceApiClient(apiClient))),
        BlocProvider(create: (_) => BranchInventoryBloc(BranchInventoryApiClient(apiClient))),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: BranchManagerAppTheme.light,
        home: const _BranchManagerAuthGate(),
      ),
    );
  }
}

class _BranchManagerAuthGate extends StatelessWidget {
  const _BranchManagerAuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return state.role.toUpperCase() == 'BRANCH_MANAGER'
              ? const BranchManagerPortalScreen()
              : const Scaffold(body: Center(child: Text(AppStrings.branchManagerOnly)));
        }
        return const LoginScreen();
      },
    );
  }
}
