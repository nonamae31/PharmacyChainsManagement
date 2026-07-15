import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_text_field.dart';
import '../../../shared/shared_components/primary_button.dart';
import '../control/stocktake_bloc.dart';
import '../control/stocktake_event.dart';
import '../control/stocktake_state.dart';
import '../entity/stocktake_request_dto.dart';

class StocktakeScreen extends StatefulWidget {
  const StocktakeScreen({super.key});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _branchController = TextEditingController();
  final _notesController = TextEditingController();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = StocktakeRequestDto(
        branchId: _branchController.text,
        stocktakeDate: DateTime.now().toIso8601String(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        items: const [], // Physical counts would be populated here
      );
      context.read<StocktakeBloc>().add(StocktakeSubmitted(request));
    }
  }

  @override
  void dispose() {
    _branchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.stocktake),
      ),
      body: BlocConsumer<StocktakeBloc, StocktakeState>(
        listener: (context, state) {
          if (state is StocktakeFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is StocktakeSuccess) {
            showAppSuccessDialog(
              context,
              message: 'Stocktake submitted successfully.',
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
                    label: 'Branch ID',
                    controller: _branchController,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AppTextField(
                    label: 'Notes (Optional)',
                    controller: _notesController,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: AppStrings.submit,
                    isLoading: state is StocktakeLoading,
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
