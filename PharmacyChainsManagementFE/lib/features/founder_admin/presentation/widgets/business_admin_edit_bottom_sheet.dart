import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/business_admin_edit_cubit.dart';
import '../cubit/business_admin_edit_state.dart';
import '../../domain/entities/business_admin_entity.dart';

import '../../../../injection_container.dart';

class BusinessAdminEditBottomSheet extends StatefulWidget {
  final BusinessAdminEntity admin;
  final VoidCallback onSuccess;

  const BusinessAdminEditBottomSheet({
    super.key,
    required this.admin,
    required this.onSuccess,
  });

  static void show(BuildContext context, BusinessAdminEntity admin, VoidCallback onSuccess) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => sl<BusinessAdminEditCubit>(),
        child: BusinessAdminEditBottomSheet(admin: admin, onSuccess: onSuccess),
      ),
    );
  }

  @override
  State<BusinessAdminEditBottomSheet> createState() => _BusinessAdminEditBottomSheetState();
}

class _BusinessAdminEditBottomSheetState extends State<BusinessAdminEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool get _hasUnsavedChanges {
    return _fullNameController.text != widget.admin.name ||
        _emailController.text != widget.admin.email ||
        _phoneController.text != widget.admin.phone;
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.admin.name);
    _phoneController = TextEditingController(text: widget.admin.phone);
    _emailController = TextEditingController(text: widget.admin.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<BusinessAdminEditCubit>().updateBusinessAdmin(
            id: widget.admin.id,
            name: _fullNameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // F-E5: PopScope warning for unsaved changes
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Push UI up when keyboard appears
          left: 20,
          right: 20,
          top: 24,
        ),
        child: BlocConsumer<BusinessAdminEditCubit, BusinessAdminEditState>(
          listener: (context, state) {
            if (state is BusinessAdminEditSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              widget.onSuccess();
              Navigator.pop(context);
            } else if (state is BusinessAdminEditError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is BusinessAdminEditLoading;

            return Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction, // F-E4: Real-time validation
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Business Admin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Semantics(
                      label: 'Full Name Input',
                      child: TextFormField(
                        key: const Key('editFullNameField'),
                        controller: _fullNameController,
                        enabled: !isLoading,
                        autofocus: true,
                        textInputAction: TextInputAction.next, // F-E3
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
                        key: const Key('editEmailField'),
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Email is required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Semantics(
                      label: 'Phone Input',
                      child: TextFormField(
                        key: const Key('editPhoneField'),
                        controller: _phoneController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone, // F-E3
                        textInputAction: TextInputAction.done, // F-E3
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

                    // F-E2: Spinner on Save button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('editSubmitBtn'),
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
                            : const Text('Save', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
