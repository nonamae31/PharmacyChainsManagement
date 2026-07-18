import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../control/auth_bloc.dart';
import '../control/auth_event.dart';
import '../control/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0: Verify Email, 1: Verify Code, 2: Reset Password, 3: Complete
  String _email = '';
  String _verifiedCode = '';

  // Step 1 Controllers
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 2 Controllers
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  // Step 3 Controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _newPassword = '';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      setState(() {
        _newPassword = _newPasswordController.text;
      });
    });
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _countdownTimer?.cancel();
        }
      });
    });
  }

  void _submitEmail() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      context.read<AuthBloc>().add(ForgotPasswordEmailSubmitted(email));
    }
  }

  void _submitCode() {
    final code = _codeControllers.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      Fluttertoast.showToast(
        msg: "Please enter the full 6-digit code.",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }
    context.read<AuthBloc>().add(ForgotPasswordCodeVerified(_email, code));
  }

  void _resendCode() {
    if (_resendCountdown == 0) {
      context.read<AuthBloc>().add(ForgotPasswordEmailSubmitted(_email));
      _startResendTimer();
    }
  }

  void _submitResetPassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (newPassword != confirmPassword) {
        Fluttertoast.showToast(
          msg: "Passwords do not match.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Check client-side complexity validations
      if (newPassword.length < 8 ||
          !newPassword.contains(RegExp(r'[A-Z]')) ||
          !newPassword.contains(RegExp(r'[a-z]')) ||
          !newPassword.contains(RegExp(r'[0-9]')) ||
          !newPassword.contains(RegExp(r'[^a-zA-Z0-9]'))) {
        Fluttertoast.showToast(
          msg: "Password does not meet complexity requirements.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      context.read<AuthBloc>().add(ForgotPasswordResetRequested(_email, _verifiedCode, newPassword));
    }
  }

  void _goBackStep() {
    setState(() {
      if (_currentStep > 0 && _currentStep < 3) {
        _currentStep--;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSendEmailSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            setState(() {
              _email = _emailController.text.trim();
              _currentStep = 1;
            });
            _startResendTimer();
          } else if (state is ForgotPasswordVerifyCodeSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            setState(() {
              _verifiedCode = _codeControllers.map((c) => c.text.trim()).join();
              _currentStep = 2;
            });
          } else if (state is ForgotPasswordResetSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            setState(() {
              _currentStep = 3;
            });
          } else if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message.replaceFirst('Exception: ', '').replaceFirst('ServerException: ', ''),
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_pharmacy,
                              color: Color(0xFF0066FF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pharmacy Chain",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                "Management System",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text("Back to Login"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 900;
                        final leftPanel = _buildLeftPanel();
                        final rightPanel = Card(
                          color: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CustomStepper(currentStep: _currentStep),
                                const SizedBox(height: 40),
                                _buildStepContent(isLoading),
                              ],
                            ),
                          ),
                        );

                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: leftPanel),
                              const SizedBox(width: 60),
                              Expanded(flex: 6, child: rightPanel),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              leftPanel,
                              const SizedBox(height: 30),
                              rightPanel,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                // Footer
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "© 2026 Pharmacy Chain Management System. All rights reserved.",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Don't worry! You can reset your password in a few simple steps.",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 40),
        // Graphic Lock Illustration
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                ),
              ),
              Positioned(
                child: Icon(
                  _currentStep == 3 ? Icons.lock_open : Icons.lock_outline,
                  size: 90,
                  color: const Color(0xFF0066FF),
                ),
              ),
              if (_currentStep >= 1)
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          "How it works",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        _buildHowItWorksItem(
          icon: Icons.person_outline,
          title: "1. Enter your email",
          subtitle: "Provide the email address associated with your account.",
        ),
        const SizedBox(height: 16),
        _buildHowItWorksItem(
          icon: Icons.mail_outline,
          title: "2. Check your email",
          subtitle: "We'll send you a verification code to your email.",
        ),
        const SizedBox(height: 16),
        _buildHowItWorksItem(
          icon: Icons.lock_outline,
          title: "3. Reset your password",
          subtitle: "Enter the code and create a new password to regain access.",
        ),
        const SizedBox(height: 30),
        // Tip caution banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: "This feature is available for ",
                      ),
                      TextSpan(
                        text: "Business Admin, Branch Manager, Inventory Manager, and Staff accounts. ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "System Admin accounts are managed directly by the system.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _buildStep1VerifyEmail(isLoading);
      case 1:
        return _buildStep2VerifyCode(isLoading);
      case 2:
        return _buildStep3ResetPassword(isLoading);
      case 3:
        return _buildStep4Complete();
      default:
        return Container();
    }
  }

  Widget _buildStep1VerifyEmail(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline, color: Color(0xFF0066FF)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Step 1: Verify Your Email",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Enter the email address associated with your account.",
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Email Address *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email address",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address.';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Info Message Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "We will send a verification code to this email address.",
                    style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Send Verification Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("or", style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Login"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2VerifyCode(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mail_outline, color: Color(0xFF0066FF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Step 2: Verify Code",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                      children: [
                        const TextSpan(text: "We have sent a 6-digit verification code to "),
                        TextSpan(
                          text: _email,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          "Verification Code *",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 12),
        // 6 Digit verification OTP Input Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              height: 55,
              child: TextFormField(
                controller: _codeControllers[index],
                focusNode: _codeFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.zero,
                  counterText: "",
                ),
                maxLength: 1,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < 5) {
                      _codeFocusNodes[index + 1].requestFocus();
                    } else {
                      _codeFocusNodes[index].unfocus();
                    }
                  } else {
                    if (index > 0) {
                      _codeFocusNodes[index - 1].requestFocus();
                    }
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        // Resend section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Didn't receive the code?",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            _resendCountdown > 0
                ? Text(
                    "Resend Code (${_resendCountdown}s)",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                  )
                : TextButton(
                    onPressed: _resendCode,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Resend Code",
                      style: TextStyle(fontSize: 14, color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 20),
        // Expiration message box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "The verification code will expire in 10 minutes.",
                  style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _goBackStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: const Color(0xFF475569),
                ),
                child: const Text("Back", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Verify Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3ResetPassword(bool isLoading) {
    // Dynamic rule validations
    final bool hasMinLength = _newPassword.length >= 8;
    final bool hasUppercase = _newPassword.contains(RegExp(r'[A-Z]'));
    final bool hasNumber = _newPassword.contains(RegExp(r'[0-9]'));
    final bool hasSpecialChar = _newPassword.contains(RegExp(r'[^a-zA-Z0-9]'));

    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: Color(0xFF0066FF)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Step 3: Reset Your Password",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Create a new password for your account.",
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "New Password *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              hintText: "Enter new password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password Rules Checklist
          _buildChecklistItem(text: "At least 8 characters long", isChecked: hasMinLength),
          const SizedBox(height: 8),
          _buildChecklistItem(text: "Contains at least one uppercase letter", isChecked: hasUppercase),
          const SizedBox(height: 8),
          _buildChecklistItem(text: "Contains at least one number", isChecked: hasNumber),
          const SizedBox(height: 8),
          _buildChecklistItem(text: "Contains at least one special character", isChecked: hasSpecialChar),
          const SizedBox(height: 24),
          const Text(
            "Confirm New Password *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: "Confirm new password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password.';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBackStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    foregroundColor: const Color(0xFF475569),
                  ),
                  child: const Text("Back", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitResetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Reset Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({required String text, required bool isChecked}) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.check_circle_outline,
          color: isChecked ? Colors.green : const Color(0xFF94A3B8),
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isChecked ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Complete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Success animation checkmark
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 64,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "Password Reset Successful!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          "Your password has been reset successfully.\nYou can now log in to your account with your new password.",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Go to Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.home_outlined),
            label: const Text("Return to Home"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomStepper extends StatelessWidget {
  final int currentStep;

  const _CustomStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStepItem(0, "Verify Email")),
        _buildLine(0),
        Expanded(child: _buildStepItem(1, "Verify Code")),
        _buildLine(1),
        Expanded(child: _buildStepItem(2, "Reset Password")),
        _buildLine(2),
        Expanded(child: _buildStepItem(3, "Complete")),
      ],
    );
  }

  Widget _buildStepItem(int stepIndex, String title) {
    final isCompleted = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.white
                    : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? const Color(0xFF0066FF)
                      : const Color(0xFFE2E8F0),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    "${stepIndex + 1}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF0066FF) : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? const Color(0xFF0066FF)
                : isCompleted
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildLine(int stepIndex) {
    final isCompleted = currentStep > stepIndex;

    return Expanded(
      child: Container(
        height: 1,
        color: isCompleted ? Colors.green : const Color(0xFFE2E8F0),
      ),
    );
  }
}
