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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  runApp(MyApp(
    authApiClient: authApiClient,
    localAuth: localAuth,
  ));
}

class MyApp extends StatelessWidget {
  final AuthApiClient authApiClient;
  final LocalAuthentication localAuth;

  const MyApp({
    super.key, 
    required this.authApiClient, 
    required this.localAuth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authApiClient: authApiClient,
            localAuth: localAuth,
          ),
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
      child: MaterialApp(
        title: 'Pharmacy Chains Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (context) => InventoryDashboardBloc(
            InventoryApiClient(Dio()),
          ),
          child: const InventoryDashboardScreen(branchId: '00000000-0000-0000-0000-000000000000'),
        ),
        routes: {
          '/admin_home': (context) => const HomeScreen(role: 'Admin'),
          '/manager_home': (context) => const HomeScreen(role: 'Manager'),
          '/user_home': (context) => const HomeScreen(role: 'User'),
          '/founder_home': (context) => const HomeScreen(role: 'Founder'),
        },
      ),
    );
  }
}
