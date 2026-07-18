import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/create_admin_cubit.dart';
import '../../../../injection_container.dart';

class CreateAdminBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const CreateAdminBottomSheet({super.key, required this.onSuccess});

  static void show(BuildContext context, VoidCallback onSuccess) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    final widget = BlocProvider(
      create: (_) => sl<CreateAdminCubit>(),
      child: CreateAdminBottomSheet(onSuccess: onSuccess),
    );

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: widget,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => widget,
      );
    }
  }

  @override
  State<CreateAdminBottomSheet> createState() => _CreateAdminBottomSheetState();
}

class _CreateAdminBottomSheetState extends State<CreateAdminBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CreateAdminCubit>().createAdmin(
            _fullNameController.text,
            _emailController.text,
            _phoneController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    // E1: Mobile-first UX (Bottom Sheet + Keyboard handling)
    return Padding(
      padding: EdgeInsets.only(
        bottom: isDesktop ? 24 : MediaQuery.of(context).viewInsets.bottom, // Đẩy UI lên khi bàn phím xuất hiện
        left: 20,
        right: 20,
        top: 24,
      ),
      child: BlocConsumer<CreateAdminCubit, CreateAdminState>(
        listener: (context, state) {
          if (state is CreateAdminSuccess) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            widget.onSuccess();
            Navigator.pop(context);
          } else if (state is CreateAdminFailure) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateAdminLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Business Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // E7: Accessibility & Tooltips (Có semantics, hint text rõ ràng)
                  Semantics(
                    label: 'Full Name Input',
                    child: TextFormField(
                      key: const Key('fullNameField'),
                      controller: _fullNameController,
                      enabled: !isLoading,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Full name is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Semantics(
                    label: 'Email Input',
                    child: TextFormField(
                      key: const Key('emailField'),
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) return 'Invalid email format';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Semantics(
                    label: 'Phone Input',
                    child: TextFormField(
                      key: const Key('phoneField'),
                      controller: _phoneController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Phone is required' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // E2: Tối ưu UI Cảm nhận (Loading state trên nút bấm)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const Key('submitBtn'),
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
