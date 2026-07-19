import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../control/auth_bloc.dart';
import 'widgets/forgot_password_step_one_form.dart';
import 'widgets/forgot_password_step_two_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  bool _isLoading = false;
  String? _errorMessage;

  final _stepOneKey = GlobalKey<FormState>();
  final _stepTwoKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleStepOne() async {
    if (!_stepOneKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final client = context.read<AuthBloc>().authApiClient;
      await client.forgotPassword(_emailController.text.trim());
      if (mounted) setState(() { _step = 2; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _handleStepTwo() async {
    if (!_stepTwoKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final client = context.read<AuthBloc>().authApiClient;
      await client.resetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        _newPassController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.passwordResetSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, _emailController.text.trim());
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _step == 1 ? AppStrings.forgotPasswordTitle : 'Xác Nhận OTP',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm)),
                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            ],
            if (_step == 1)
              ForgotPasswordStepOneForm(
                emailController: _emailController,
                formKey: _stepOneKey,
                isLoading: _isLoading,
                onSubmit: _handleStepOne,
              )
            else
              ForgotPasswordStepTwoForm(
                otpController: _otpController,
                newPassController: _newPassController,
                confirmPassController: _confirmPassController,
                formKey: _stepTwoKey,
                isLoading: _isLoading,
                onSubmit: _handleStepTwo,
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
