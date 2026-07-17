import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../entity/shipment_dto.dart';

class ShipmentDialog extends StatefulWidget {
  final ShipmentOptionsDto options;

  const ShipmentDialog({super.key, required this.options});

  @override
  State<ShipmentDialog> createState() => _ShipmentDialogState();
}

class _ShipmentDialogState extends State<ShipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  late String _branchId = widget.options.sourceBranches.first.branchId;
  late String _batchId = _availableBatches.first.batchId;

  List<TransferBatchOptionDto> get _availableBatches => widget.options.batches
      .where((item) => item.branchId == _branchId)
      .toList(growable: false);

  TransferBatchOptionDto get _selectedBatch =>
      _availableBatches.firstWhere((item) => item.batchId == _batchId);

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batches = _availableBatches;
    return AlertDialog(
      title: const Text(AppStrings.newShipment),
      content: SizedBox(
        width: AppSpacing.dialogWidthWide,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _branchId,
                  decoration: const InputDecoration(
                    labelText: AppStrings.sourceBranch,
                  ),
                  items: widget.options.sourceBranches
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.branchId,
                          child: Text(item.branchName),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _branchId = value;
                      _batchId = _availableBatches.first.batchId;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  key: ValueKey(_branchId),
                  initialValue: _batchId,
                  decoration: const InputDecoration(
                    labelText: AppStrings.medicineBatch,
                  ),
                  items: batches
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.batchId,
                          child: Text(
                            '${item.medicineName} · ${item.batchNumber} (${item.availableQuantity})',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setState(() => _batchId = value!),
                ),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.quantity,
                    helperText:
                        '${AppStrings.available}: ${_selectedBatch.availableQuantity}',
                  ),
                  validator: (value) {
                    final quantity = int.tryParse(value ?? '');
                    if (quantity == null || quantity < 1) {
                      return AppStrings.invalidQuantity;
                    }
                    if (quantity > _selectedBatch.availableQuantity) {
                      return AppStrings.quantityExceedsStock;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: AppStrings.notes,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(AppStrings.createRequest),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      CreateShipmentRequestDto(
        fromBranchId: _branchId,
        batchId: _batchId,
        quantity: int.parse(_quantityController.text),
        notes: _notesController.text.trim(),
      ),
    );
  }
}
