import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/deactivate_admin_cubit.dart';
import '../cubit/deactivate_admin_state.dart';

class DeactivateAdminDialog extends StatefulWidget {
  final String adminId;

  const DeactivateAdminDialog({super.key, required this.adminId});

  @override
  State<DeactivateAdminDialog> createState() => _DeactivateAdminDialogState();
}

class _DeactivateAdminDialogState extends State<DeactivateAdminDialog> {
  final _reasonController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _reasonController.text.trim().length >= 10;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeactivateAdminCubit, DeactivateAdminState>(
      listener: (context, state) {
        if (state is DeactivateAdminSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is DeactivateAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is DeactivateAdminLoading;

        return AlertDialog(
          title: const Text('Vô hiệu hóa Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hành động vô hiệu hoá sẽ được lưu lại trong hệ thống và thông báo qua email cho Admin này.',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do vô hiệu hóa (ít nhất 10 ký tự)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: (_isButtonEnabled && !isLoading)
                  ? () {
                      final reason = _reasonController.text.trim();
                      context.read<DeactivateAdminCubit>().deactivateAdmin(widget.adminId, reason);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }
}
