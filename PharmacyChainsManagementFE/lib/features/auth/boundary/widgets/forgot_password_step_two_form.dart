import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/shared_components/primary_button.dart';

class ForgotPasswordStepTwoForm extends StatelessWidget {
  final TextEditingController otpController;
  final TextEditingController newPassController;
  final TextEditingController confirmPassController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ForgotPasswordStepTwoForm({
    super.key,
    required this.otpController,
    required this.newPassController,
    required this.confirmPassController,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.otpSentSuccess,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: AppStrings.otpLabel,
              hintText: AppStrings.otpHint,
              prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd)),
              counterText: '',
            ),
            validator: (value) => (value == null || value.length < 6) ? 'Vui lòng nhập đủ 6 số OTP' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: newPassController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.newPasswordLabel,
              hintText: AppStrings.newPasswordHint,
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd)),
            ),
            validator: (value) => (value == null || value.length < 6) ? 'Mật khẩu phải từ 6 ký tự' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: confirmPassController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPasswordLabel,
              hintText: AppStrings.confirmPasswordHint,
              prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd)),
            ),
            validator: (value) => value != newPassController.text ? 'Mật khẩu xác nhận không khớp' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            text: AppStrings.resetPasswordButton,
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
