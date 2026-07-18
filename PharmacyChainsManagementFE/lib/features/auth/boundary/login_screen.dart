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
            String displayMsg = state.message;
            if (displayMsg.contains('refused') || displayMsg.contains('Connection errored') || displayMsg.contains('SocketException')) {
              displayMsg = 'Lỗi kết nối: Backend chưa bật (máy chủ từ chối kết nối cổng 7000). Vui lòng chạy dotnet run trong thư mục BE!';
            }
            try {
              Fluttertoast.showToast(
                msg: displayMsg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } catch (_) {}
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(displayMsg, style: const TextStyle(color: Colors.white, fontSize: 14)),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
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
