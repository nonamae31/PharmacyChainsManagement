import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../entity/staff_sales_dto.dart';

class InvoiceMedicineTable extends StatelessWidget {
  final List<InvoiceDraftLineModel> lines;
  final void Function(String medicineId, String quantity) onQuantityChanged;
  final ValueChanged<String> onRemove;

  const InvoiceMedicineTable({
    super.key,
    required this.lines,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: Text(AppStrings.noMedicinesAdded)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSpacing.mobileContentBreakpoint) {
          return Column(
            children: lines
                .map(
                  (line) => _InvoiceMedicineCard(
                    line: line,
                    onQuantityChanged: onQuantityChanged,
                    onRemove: onRemove,
                  ),
                )
                .toList(),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text(AppStrings.medicine)),
              DataColumn(label: Text(AppStrings.availableStock), numeric: true),
              DataColumn(label: Text(AppStrings.quantity), numeric: true),
              DataColumn(label: Text(AppStrings.unitPrice), numeric: true),
              DataColumn(label: Text(AppStrings.itemTotal), numeric: true),
              DataColumn(label: Text(AppStrings.action)),
            ],
            rows: lines
                .map(
                  (line) => DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 210,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.medicine.medicineName,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                line.medicine.unit,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text('${line.medicine.availableQuantity}')),
                      DataCell(
                        _QuantityField(
                          line: line,
                          onQuantityChanged: onQuantityChanged,
                        ),
                      ),
                      DataCell(
                        Text(
                          '${CurrencyConstants.usdSymbol}'
                          '${line.medicine.unitPrice.toStringAsFixed(2)}',
                        ),
                      ),
                      DataCell(
                        Text(
                          '${CurrencyConstants.usdSymbol}'
                          '${line.lineTotal.toStringAsFixed(2)}',
                        ),
                      ),
                      DataCell(
                        IconButton(
                          tooltip: AppStrings.removeMedicine,
                          onPressed: () => onRemove(line.medicine.medicineId),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _InvoiceMedicineCard extends StatelessWidget {
  final InvoiceDraftLineModel line;
  final void Function(String medicineId, String quantity) onQuantityChanged;
  final ValueChanged<String> onRemove;

  const _InvoiceMedicineCard({
    required this.line,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.medicine.medicineName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      line.medicine.unit,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppStrings.removeMedicine,
                onPressed: () => onRemove(line.medicine.medicineId),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MedicineValue(
                label: AppStrings.availableStock,
                value: '${line.medicine.availableQuantity}',
              ),
              SizedBox(
                width: AppSpacing.xxxl * 2,
                child: _QuantityField(
                  line: line,
                  onQuantityChanged: onQuantityChanged,
                  labelText: AppStrings.quantity,
                ),
              ),
              _MedicineValue(
                label: AppStrings.unitPrice,
                value:
                    '${CurrencyConstants.usdSymbol}'
                    '${line.medicine.unitPrice.toStringAsFixed(2)}',
              ),
              _MedicineValue(
                label: AppStrings.itemTotal,
                value:
                    '${CurrencyConstants.usdSymbol}'
                    '${line.lineTotal.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _MedicineValue extends StatelessWidget {
  final String label;
  final String value;

  const _MedicineValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xs),
      Text(value, style: Theme.of(context).textTheme.titleSmall),
    ],
  );
}

class _QuantityField extends StatelessWidget {
  final InvoiceDraftLineModel line;
  final void Function(String medicineId, String quantity) onQuantityChanged;
  final String? labelText;

  const _QuantityField({
    required this.line,
    required this.onQuantityChanged,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 84,
    child: TextFormField(
      key: ValueKey('${line.medicine.medicineId}-${line.quantity}'),
      initialValue: '${line.quantity}',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: (value) =>
          onQuantityChanged(line.medicine.medicineId, value),
      decoration: InputDecoration(
        labelText: labelText,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
