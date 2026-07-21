import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../../../../shared/shared_components/app_error_snack_bar.dart';
import '../../../../shared/shared_components/app_loading_indicator.dart';
import '../../../../shared/shared_components/app_text_field.dart';
import '../../../../shared/shared_components/primary_button.dart';
import '../../control/staff_sales_bloc.dart';
import '../../control/staff_sales_event.dart';
import '../../control/staff_sales_state.dart';
import '../../entity/staff_sales_dto.dart';

Future<MedicineDto?> showMedicineSelectionDialog(BuildContext context) {
  return showDialog<MedicineDto>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) =>
          sl<StaffSalesBloc>()..add(const MedicineSearchRequested(null)),
      child: const _MedicineSelectionDialog(),
    ),
  );
}

class _MedicineSelectionDialog extends StatefulWidget {
  const _MedicineSelectionDialog();

  @override
  State<_MedicineSelectionDialog> createState() =>
      _MedicineSelectionDialogState();
}

class _MedicineSelectionDialogState extends State<_MedicineSelectionDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<StaffSalesBloc>().add(
      MedicineSearchRequested(_searchController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.selectMedicine,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.close,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final searchField = AppTextField(
                    label: AppStrings.searchMedicine,
                    controller: _searchController,
                  );
                  final searchButton = PrimaryButton(
                    text: AppStrings.search,
                    onPressed: _search,
                  );
                  if (constraints.maxWidth <
                      AppSpacing.mobileContentBreakpoint) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: AppSpacing.sm),
                        searchButton,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: searchField),
                      const SizedBox(width: AppSpacing.md),
                      searchButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
                  listener: (context, state) {
                    if (state is StaffSalesLoadFailure) {
                      showAppErrorSnackBar(context, message: state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state is StaffSalesLoading) {
                      return const AppLoadingIndicator();
                    }
                    if (state is MedicineSearchLoadSuccess) {
                      return _MedicineTable(medicines: state.medicines);
                    }
                    return const Center(
                      child: Text(AppStrings.noMedicinesFound),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineTable extends StatelessWidget {
  final List<MedicineDto> medicines;
  const _MedicineTable({required this.medicines});

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return const Center(child: Text(AppStrings.noMedicinesFound));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSpacing.mobileContentBreakpoint) {
          return ListView.separated(
            key: const Key('medicine-selection-mobile-list'),
            itemCount: medicines.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) =>
                _MedicineSelectionCard(medicine: medicines[index]),
          );
        }
        return Scrollbar(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text(AppStrings.medicine)),
                  DataColumn(label: Text(AppStrings.category)),
                  DataColumn(label: Text(AppStrings.unit)),
                  DataColumn(label: Text(AppStrings.unitPrice), numeric: true),
                  DataColumn(
                    label: Text(AppStrings.availableStock),
                    numeric: true,
                  ),
                  DataColumn(label: Text(AppStrings.action)),
                ],
                rows: medicines
                    .map(
                      (medicine) => DataRow(
                        cells: [
                          DataCell(Text(medicine.medicineName)),
                          DataCell(
                            Text(medicine.category ?? AppStrings.notAvailable),
                          ),
                          DataCell(Text(medicine.unit)),
                          DataCell(
                            Text(
                              '${CurrencyConstants.usdSymbol}'
                              '${medicine.unitPrice.toStringAsFixed(2)}',
                            ),
                          ),
                          DataCell(Text('${medicine.availableQuantity}')),
                          DataCell(
                            FilledButton(
                              onPressed: medicine.availableQuantity > 0
                                  ? () => Navigator.pop(context, medicine)
                                  : null,
                              child: const Text(AppStrings.choose),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MedicineSelectionCard extends StatelessWidget {
  final MedicineDto medicine;

  const _MedicineSelectionCard({required this.medicine});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            medicine.medicineName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MedicineDetailRow(
            label: AppStrings.category,
            value: medicine.category ?? AppStrings.notAvailable,
          ),
          _MedicineDetailRow(label: AppStrings.unit, value: medicine.unit),
          _MedicineDetailRow(
            label: AppStrings.unitPrice,
            value:
                '${CurrencyConstants.usdSymbol}'
                '${medicine.unitPrice.toStringAsFixed(2)}',
          ),
          _MedicineDetailRow(
            label: AppStrings.availableStock,
            value: '${medicine.availableQuantity}',
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: medicine.availableQuantity > 0
                ? () => Navigator.pop(context, medicine)
                : null,
            child: const Text(AppStrings.choose),
          ),
        ],
      ),
    ),
  );
}

class _MedicineDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _MedicineDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, textAlign: TextAlign.end, softWrap: true)),
      ],
    ),
  );
}
