import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/routes/app_router.dart';
import 'features/auth/control/auth_bloc.dart';
import 'features/auth/network/auth_api_client.dart';

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
    if (Firebase.apps.isEmpty) {
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
