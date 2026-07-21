import 'package:flutter/material.dart';

import '../../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/primary_button.dart';
import '../../entity/stock_replenishment_dto.dart';

class BranchReplenishmentFormDialog extends StatefulWidget {
  final List<StockReplenishmentOptionDto> options;
  final bool submitting;
  final ValueChanged<CreateStockReplenishmentRequestDto> onSubmit;

  const BranchReplenishmentFormDialog({
    super.key,
    required this.options,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  State<BranchReplenishmentFormDialog> createState() =>
      _BranchReplenishmentFormDialogState();
}

class _BranchReplenishmentFormDialogState
    extends State<BranchReplenishmentFormDialog> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final List<CreateStockReplenishmentItemDto> _items = [];
  String? _selectedMedicineId;
  String _priority = 'NORMAL';
  String? _itemError;

  @override
  void initState() {
    super.initState();
    _selectedMedicineId = widget.options.isEmpty
        ? null
        : widget.options.first.medicineId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(StockReplenishmentAppStrings.createRequest),
      content: SizedBox(
        width: AppSpacing.dialogWidthWide,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequestInputRow(
                options: widget.options,
                selectedMedicineId: _selectedMedicineId,
                quantityController: _quantityController,
                onMedicineChanged: (value) =>
                    setState(() => _selectedMedicineId = value),
                onAdd: _addItem,
              ),
              if (_itemError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _itemError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _DraftItems(
                items: _items,
                options: widget.options,
                onRemove: _removeItem,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: StockReplenishmentAppStrings.priority,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'NORMAL',
                    child: Text(StockReplenishmentAppStrings.normal),
                  ),
                  DropdownMenuItem(
                    value: 'URGENT',
                    child: Text(StockReplenishmentAppStrings.urgent),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _priority = value ?? 'NORMAL'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: StockReplenishmentAppStrings.optionalNotes,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.submitting
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text(StockReplenishmentAppStrings.cancel),
        ),
        PrimaryButton(
          text: StockReplenishmentAppStrings.submitRequest,
          isLoading: widget.submitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  void _addItem() {
    final medicineId = _selectedMedicineId;
    final quantity = int.tryParse(_quantityController.text.trim());
    if (medicineId == null ||
        quantity == null ||
        quantity < 1 ||
        quantity > 100000) {
      setState(() => _itemError = StockReplenishmentAppStrings.invalidQuantity);
      return;
    }
    if (_items.any((item) => item.medicineId == medicineId)) {
      setState(
        () => _itemError = StockReplenishmentAppStrings.duplicateMedicine,
      );
      return;
    }

    setState(() {
      _items.add(
        CreateStockReplenishmentItemDto(
          medicineId: medicineId,
          quantity: quantity,
        ),
      );
      _quantityController.clear();
      _itemError = null;
    });
  }

  void _removeItem(String medicineId) {
    setState(() => _items.removeWhere((item) => item.medicineId == medicineId));
  }

  void _submit() {
    if (_items.isEmpty) {
      setState(
        () => _itemError = StockReplenishmentAppStrings.atLeastOneMedicine,
      );
      return;
    }
    final notes = _notesController.text.trim();
    widget.onSubmit(
      CreateStockReplenishmentRequestDto(
        priority: _priority,
        notes: notes.isEmpty ? null : notes,
        items: List.unmodifiable(_items),
      ),
    );
  }
}

class _RequestInputRow extends StatelessWidget {
  final List<StockReplenishmentOptionDto> options;
  final String? selectedMedicineId;
  final TextEditingController quantityController;
  final ValueChanged<String?> onMedicineChanged;
  final VoidCallback onAdd;

  const _RequestInputRow({
    required this.options,
    required this.selectedMedicineId,
    required this.quantityController,
    required this.onMedicineChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: AppSpacing.replenishmentMedicineFieldWidth,
          child: DropdownButtonFormField<String>(
            initialValue: selectedMedicineId,
            decoration: const InputDecoration(
              labelText: StockReplenishmentAppStrings.medicine,
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option.medicineId,
                    child: Text(
                      '${option.medicineName} (${option.currentStock} ${option.unit})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onMedicineChanged,
          ),
        ),
        SizedBox(
          width: AppSpacing.replenishmentQuantityFieldWidth,
          child: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: StockReplenishmentAppStrings.quantity,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: options.isEmpty ? null : onAdd,
          icon: const Icon(Icons.add),
          label: const Text(StockReplenishmentAppStrings.addMedicine),
        ),
      ],
    );
  }
}

class _DraftItems extends StatelessWidget {
  final List<CreateStockReplenishmentItemDto> items;
  final List<StockReplenishmentOptionDto> options;
  final ValueChanged<String> onRemove;

  const _DraftItems({
    required this.items,
    required this.options,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        StockReplenishmentAppStrings.atLeastOneMedicine,
        style: AppTextStyles.caption,
      );
    }
    return Column(
      children: items
          .map((item) {
            final option = options.firstWhere(
              (candidate) => candidate.medicineId == item.medicineId,
            );
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication_outlined),
              title: Text(option.medicineName),
              subtitle: Text(
                '${StockReplenishmentAppStrings.currentStock}: ${option.currentStock} ${option.unit}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${item.quantity} ${option.unit}'),
                  IconButton(
                    tooltip: StockReplenishmentAppStrings.removeMedicine,
                    onPressed: () => onRemove(item.medicineId),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
