import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/currency_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../injection_container.dart';
import '../../../shared/shared_components/app_error_snack_bar.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/staff_sales_bloc.dart';
import '../control/staff_sales_event.dart';
import '../control/staff_sales_state.dart';
import '../entity/staff_sales_dto.dart';
import 'widgets/staff_workspace_shell.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<StaffSalesBloc>()..add(InvoiceDetailRequested(invoiceId)),
    child: const _InvoiceDetailView(),
  );
}

class _InvoiceDetailView extends StatelessWidget {
  const _InvoiceDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffSalesBloc, StaffSalesState>(
      listener: (context, state) {
        if (state is StaffSalesLoadFailure) {
          showAppErrorSnackBar(context, message: state.message);
        }
      },
      builder: (context, state) => StaffWorkspaceShell(
        title: AppStrings.invoiceDetails,
        subtitle: AppStrings.invoiceDetailsDescription,
        section: StaffWorkspaceSection.invoices,
        actions: [
          OutlinedButton.icon(
            onPressed: () => context.go('/staff/invoices'),
            icon: const Icon(Icons.arrow_back),
            label: const Text(AppStrings.backToInvoices),
          ),
        ],
        child: switch (state) {
          StaffSalesLoading() => const AppLoadingIndicator(),
          InvoiceDetailLoadSuccess(:final invoice) => _InvoiceDetailContent(
            invoice: invoice,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _InvoiceDetailContent extends StatelessWidget {
  final InvoiceDto invoice;

  const _InvoiceDetailContent({required this.invoice});

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      _InvoiceInformationCard(invoice: invoice),
      const SizedBox(height: AppSpacing.md),
      _InvoiceItemsCard(items: invoice.items),
    ],
  );
}

class _InvoiceInformationCard extends StatelessWidget {
  final InvoiceDto invoice;

  const _InvoiceInformationCard({required this.invoice});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        children: [
          _InformationItem(
            label: AppStrings.invoiceCode,
            value: invoice.invoiceCode,
          ),
          _InformationItem(
            label: AppStrings.invoiceDate,
            value: invoice.invoiceDate,
          ),
          _InformationItem(
            label: AppStrings.paymentStatus,
            value: invoice.paymentStatus,
          ),
          _InformationItem(
            label: AppStrings.invoiceStatus,
            value: invoice.status,
          ),
          _InformationItem(
            label: AppStrings.totalAmount,
            value: invoice.totalAmount.toStringAsFixed(0),
          ),
        ],
      ),
    ),
  );
}

class _InformationItem extends StatelessWidget {
  final String label;
  final String value;

  const _InformationItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xs),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _InvoiceItemsCard extends StatelessWidget {
  final List<InvoiceLineDto> items;

  const _InvoiceItemsCard({required this.items});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.invoiceMedicines,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text(AppStrings.medicine)),
                DataColumn(label: Text(AppStrings.batchNumber)),
                DataColumn(label: Text(AppStrings.quantity), numeric: true),
                DataColumn(label: Text(AppStrings.unitPrice), numeric: true),
                DataColumn(label: Text(AppStrings.itemTotal), numeric: true),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.medicineName)),
                        DataCell(Text(item.batchNumber)),
                        DataCell(Text('${item.quantity}')),
                        DataCell(
                          Text(
                            '${CurrencyConstants.usdSymbol}'
                            '${item.unitPrice.toStringAsFixed(2)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${CurrencyConstants.usdSymbol}'
                            '${item.lineTotal.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
