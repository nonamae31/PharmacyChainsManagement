import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../control/auth_bloc.dart';
import '../../control/auth_event.dart';
import '../../control/auth_state.dart';

class LoginFormWidget extends StatefulWidget {
  final bool isLogin;
  const LoginFormWidget({super.key, required this.isLogin});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  late bool isLogin;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  Future<bool> _hasInternet() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    if (connectivityResults.contains(ConnectivityResult.none) || connectivityResults.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Internet Connection'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!mounted) return;
      if (isLogin) {
        context.read<AuthBloc>().add(LoginRequested(email, password));
      } else {
        context.read<AuthBloc>().add(RegisterRequested(email, password));
      }
    }
  }

  Future<void> _onGoogleLogin() async {
    FocusScope.of(context).unfocus();
    
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Internet Connection'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (!mounted) return;
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLogin ? 'Welcome Back' : 'Create Account',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('emailField'),
            controller: _emailController,
            focusNode: _emailFocus,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            focusNode: _passwordFocus,
            decoration: InputDecoration(
              labelText: 'Password', 
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthLoading) _submit();
            },
          ),
          const SizedBox(height: 24),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  key: const Key('loginButton'),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(isLogin ? 'Login' : 'Register', style: const TextStyle(fontSize: 16)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return InkWell(
                onTap: isLoading ? null : _onGoogleLogin,
                child: isLoading 
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: _buildGoogleButton(),
                      )
                    : _buildGoogleButton(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.g_mobiledata, size: 32, color: Colors.red[600]),
          const SizedBox(width: 8),
          const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
