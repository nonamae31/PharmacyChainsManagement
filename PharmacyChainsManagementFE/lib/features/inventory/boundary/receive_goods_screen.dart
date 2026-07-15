import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_text_field.dart';
import '../../../shared/shared_components/primary_button.dart';
import '../control/receive_goods_bloc.dart';
import '../control/receive_goods_event.dart';
import '../control/receive_goods_state.dart';
import '../entity/receive_goods_request_dto.dart';

class ReceiveGoodsScreen extends StatefulWidget {
  const ReceiveGoodsScreen({super.key});

  @override
  State<ReceiveGoodsScreen> createState() => _ReceiveGoodsScreenState();
}

class _ReceiveGoodsScreenState extends State<ReceiveGoodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _poController = TextEditingController();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = ReceiveGoodsRequestDto(
        supplierId: _supplierController.text,
        poId: _poController.text.isNotEmpty ? _poController.text : null,
        receivedDate: DateTime.now().toIso8601String(),
        items: const [], // In a real app, this would be populated dynamically
      );
      context.read<ReceiveGoodsBloc>().add(ReceiveGoodsSubmitted(request));
    }
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _poController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.receiveGoods),
      ),
      body: BlocConsumer<ReceiveGoodsBloc, ReceiveGoodsState>(
        listener: (context, state) {
          if (state is ReceiveGoodsFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is ReceiveGoodsSuccess) {
            showAppSuccessDialog(
              context,
              message: 'Goods received successfully!',
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
                    label: 'Supplier ID',
                    controller: _supplierController,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AppTextField(
                    label: 'PO ID (Optional)',
                    controller: _poController,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: AppStrings.submit,
                    isLoading: state is ReceiveGoodsLoading,
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
