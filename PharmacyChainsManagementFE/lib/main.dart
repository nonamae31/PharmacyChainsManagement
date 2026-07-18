import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:dio/dio.dart';

import 'core/network/branch_manager_api_client_base.dart';
import 'core/routes/app_router.dart';
import 'firebase_options.dart';
import 'features/auth/control/auth_bloc.dart';
import 'features/auth/control/auth_event.dart';
import 'features/auth/network/auth_api_client.dart';
import 'features/inventory/control/inventory_dashboard_bloc.dart';
import 'features/inventory/control/stocktake_bloc.dart';
import 'features/inventory/control/receive_goods_bloc.dart';
import 'features/inventory/control/issue_stock_bloc.dart';
import 'features/inventory/network/inventory_api_client.dart';
import 'features/branch_dashboard/control/branch_dashboard_bloc.dart';
import 'features/branch_dashboard/network/branch_dashboard_api_client.dart';
import 'features/branch_inventory/control/branch_inventory_bloc.dart';
import 'features/branch_inventory/network/branch_inventory_api_client.dart';
import 'features/branch_revenue/control/branch_revenue_bloc.dart';
import 'features/branch_revenue/network/branch_revenue_api_client.dart';
import 'features/staff_performance/control/staff_performance_bloc.dart';
import 'features/staff_performance/network/staff_performance_api_client.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Could not load .env file: $error');
  }

  try {
    if (!kIsWeb && Firebase.apps.isEmpty) {
      // Bypass Firebase on web for now due to dummy config
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error) {
    debugPrint('Firebase init error: $error');
  }

  final authApiClient = AuthApiClient();
  final localAuth = LocalAuthentication();
  final authBloc = AuthBloc(authApiClient: authApiClient, localAuth: localAuth)
    ..add(AuthCheckRequested());
  final branchManagerApiClient = BranchManagerApiClientBase();
  final appRouter = AppRouter(authBloc);

  runApp(
    MyApp(
      authApiClient: authApiClient,
      localAuth: localAuth,
      appRouter: appRouter,
      authBloc: authBloc,
      branchManagerApiClient: branchManagerApiClient,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authApiClient,
    required this.localAuth,
    required this.appRouter,
    required this.authBloc,
    required this.branchManagerApiClient,
  });

  final AuthApiClient authApiClient;
  final LocalAuthentication localAuth;
  final AppRouter appRouter;
  final AuthBloc authBloc;
  final BranchManagerApiClientBase branchManagerApiClient;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider(
          create: (_) => BranchDashboardBloc(
            BranchDashboardApiClient(branchManagerApiClient),
          ),
        ),
        BlocProvider(
          create: (_) =>
              BranchRevenueBloc(BranchRevenueApiClient(branchManagerApiClient)),
        ),
        BlocProvider(
          create: (_) => StaffPerformanceBloc(
            StaffPerformanceApiClient(branchManagerApiClient),
          ),
        ),
        BlocProvider(
          create: (_) => BranchInventoryBloc(
            BranchInventoryApiClient(branchManagerApiClient),
          ),
        ),
        BlocProvider<InventoryDashboardBloc>(
          create: (context) =>
              InventoryDashboardBloc(InventoryApiClient(Dio())),
        ),
        BlocProvider<StocktakeBloc>(
          create: (context) => StocktakeBloc(InventoryApiClient(Dio())),
        ),
        BlocProvider<ReceiveGoodsBloc>(
          create: (context) => ReceiveGoodsBloc(InventoryApiClient(Dio())),
        ),
        BlocProvider<IssueStockBloc>(
          create: (context) => IssueStockBloc(InventoryApiClient(Dio())),
        ),
      ],
      child: MaterialApp.router(
        title: 'Pharmacy Chains Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
