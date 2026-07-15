import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

void showAppErrorDialog(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          AppStrings.error,
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      );
    },
  );
}

void showAppSuccessDialog(BuildContext context, {required String message, VoidCallback? onClose}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          AppStrings.success,
          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onClose != null) onClose();
            },
            child: const Text(AppStrings.close),
          ),
        ],
      );
    },
  );
}
