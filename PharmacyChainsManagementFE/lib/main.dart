import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/routes/app_router.dart';
import 'features/auth/control/auth_bloc.dart';
import 'features/auth/network/auth_api_client.dart';
import 'features/business_admin/control/business_admin_bloc.dart';
import 'features/business_admin/network/business_admin_api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  final authApiClient = AuthApiClient();
  final businessAdminApiClient = BusinessAdminApiClient();
  final localAuth = LocalAuthentication();

  final authBloc = AuthBloc(authApiClient: authApiClient, localAuth: localAuth);
  final businessAdminBloc = BusinessAdminBloc(
    businessAdminApiClient: businessAdminApiClient,
  );
  final appRouter = AppRouter(authBloc);

  runApp(
    MyApp(
      authApiClient: authApiClient,
      localAuth: localAuth,
      appRouter: appRouter,
      authBloc: authBloc,
      businessAdminBloc: businessAdminBloc,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthApiClient authApiClient;
  final LocalAuthentication localAuth;
  final AppRouter appRouter;
  final AuthBloc authBloc;
  final BusinessAdminBloc businessAdminBloc;

  const MyApp({
    super.key,
    required this.authApiClient,
    required this.localAuth,
    required this.appRouter,
    required this.authBloc,
    required this.businessAdminBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<BusinessAdminBloc>.value(value: businessAdminBloc),
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
