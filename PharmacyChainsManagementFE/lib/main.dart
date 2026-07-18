import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

import 'package:dio/dio.dart';
import 'features/auth/boundary/login_screen.dart';
import 'features/auth/control/auth_bloc.dart';
import 'features/auth/network/auth_api_client.dart';
import 'features/home/boundary/home_screen.dart';
import 'features/inventory/boundary/inventory_dashboard_screen.dart';
import 'features/inventory/control/inventory_dashboard_bloc.dart';
import 'features/inventory/control/stocktake_bloc.dart';
import 'features/inventory/control/receive_goods_bloc.dart';
import 'features/inventory/control/issue_stock_bloc.dart';
import 'features/inventory/network/inventory_api_client.dart';
import 'core/routes/app_router.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }
  
  try {
    if (!kIsWeb && Firebase.apps.isEmpty) { // Bypass Firebase on web for now due to dummy config
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  
  final authApiClient = AuthApiClient();
  final localAuth = LocalAuthentication();

  final authBloc = AuthBloc(
    authApiClient: authApiClient,
    localAuth: localAuth,
  );
  final appRouter = AppRouter(authBloc);

  runApp(MyApp(
    authApiClient: authApiClient,
    localAuth: localAuth,
    appRouter: appRouter,
    authBloc: authBloc,
  ));
}

class MyApp extends StatelessWidget {
  final AuthApiClient authApiClient;
  final LocalAuthentication localAuth;
  final AppRouter appRouter;
  final AuthBloc authBloc;

  const MyApp({
    super.key, 
    required this.authApiClient, 
    required this.localAuth,
    required this.appRouter,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: authBloc,
        ),
        BlocProvider<InventoryDashboardBloc>(
          create: (context) => InventoryDashboardBloc(
            InventoryApiClient(Dio()),
          ),
        ),
        BlocProvider<StocktakeBloc>(
          create: (context) => StocktakeBloc(
            InventoryApiClient(Dio()),
          ),
        ),
        BlocProvider<ReceiveGoodsBloc>(
          create: (context) => ReceiveGoodsBloc(
            InventoryApiClient(Dio()),
          ),
        ),
        BlocProvider<IssueStockBloc>(
          create: (context) => IssueStockBloc(
            InventoryApiClient(Dio()),
          ),
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
