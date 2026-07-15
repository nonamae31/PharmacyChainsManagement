import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_text_field.dart';
import '../../../shared/shared_components/primary_button.dart';
import '../control/issue_stock_bloc.dart';
import '../control/issue_stock_event.dart';
import '../control/issue_stock_state.dart';
import '../entity/issue_stock_request_dto.dart';

class IssueStockScreen extends StatefulWidget {
  const IssueStockScreen({super.key});

  @override
  State<IssueStockScreen> createState() => _IssueStockScreenState();
}

class _IssueStockScreenState extends State<IssueStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeController = TextEditingController();
  final _requestNoController = TextEditingController();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = IssueStockRequestDto(
        storeId: _storeController.text,
        requestNo: _requestNoController.text,
        items: const [], // In a real app, items would be added dynamically
      );
      context.read<IssueStockBloc>().add(IssueStockSubmitted(request));
    }
  }

  @override
  void dispose() {
    _storeController.dispose();
    _requestNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.issueStock),
      ),
      body: BlocConsumer<IssueStockBloc, IssueStockState>(
        listener: (context, state) {
          if (state is IssueStockFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is IssueStockSuccess) {
            showAppSuccessDialog(
              context,
              message: 'Stock issued successfully (FEFO).',
              onClose: () => Navigator.of(context).pop(),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Store ID',
                    controller: _storeController,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AppTextField(
                    label: 'Request No.',
                    controller: _requestNoController,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: AppStrings.submit,
                    isLoading: state is IssueStockLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
