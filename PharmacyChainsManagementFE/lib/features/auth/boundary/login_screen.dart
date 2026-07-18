import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../control/auth_bloc.dart';
import '../control/auth_state.dart';
import 'widgets/login_mobile_layout.dart';
import 'widgets/login_web_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (state is AuthAuthenticated) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            final role = state.role.toLowerCase();
            switch (role) {
              case 'founder':
                context.go('/founder_home');
                break;
              case 'business_admin':
                context.go('/business_admin_home');
                break;
              case 'branch_manager':
                context.go('/branch_manager_home');
                break;
              case 'staff':
                context.go('/staff_home');
                break;
              case 'inventory_manager':
                context.go('/inventory_home');
                break;
              default:
                context.go('/login');
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return const LoginWebLayout();
            } else {
              return const LoginMobileLayout();
            }
          },
        ),
      ),
    );
  }
}
