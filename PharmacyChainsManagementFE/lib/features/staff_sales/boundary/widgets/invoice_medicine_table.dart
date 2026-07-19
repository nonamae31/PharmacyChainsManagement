import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
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
                    SizedBox(
                      width: 84,
                      child: TextFormField(
                        key: ValueKey(
                          '${line.medicine.medicineId}-${line.quantity}',
                        ),
                        initialValue: '${line.quantity}',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (value) =>
                            onQuantityChanged(line.medicine.medicineId, value),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(line.medicine.unitPrice.toStringAsFixed(2))),
                  DataCell(Text(line.lineTotal.toStringAsFixed(2))),
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
  }
}
