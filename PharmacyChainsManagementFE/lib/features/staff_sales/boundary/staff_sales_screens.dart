import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../injection_container.dart';
import '../../../shared/shared_components/app_error_snack_bar.dart';
import '../control/staff_sales_bloc.dart';
import '../control/staff_sales_event.dart';
import '../control/staff_sales_state.dart';
import '../entity/staff_sales_dto.dart';
import 'widgets/invoice_medicine_table.dart';
import 'widgets/medicine_selection_dialog.dart';
import 'widgets/payment_qr_card.dart';
import 'widgets/staff_workspace_shell.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<StaffSalesBloc>()..add(StaffDashboardRequested()),
    child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
      listener: _listen,
      builder: (context, state) => StaffWorkspaceShell(
        title: 'Branch dashboard',
        subtitle: 'Overview of your pharmacy operations today.',
        section: StaffWorkspaceSection.dashboard,
        child: state is StaffDashboardLoadSuccess
            ? _DashboardContent(dashboard: state.dashboard)
            : const _PageLoading(),
      ),
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  final StaffDashboardDto dashboard;
  const _DashboardContent({required this.dashboard});
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _MetricCard(
            'Daily revenue',
            dashboard.todayRevenue.toStringAsFixed(0),
            Icons.payments_outlined,
          ),
          _MetricCard(
            'Invoices today',
            dashboard.todayInvoiceCount.toString(),
            Icons.receipt_long_outlined,
          ),
          _MetricCard(
            'Pending payments',
            dashboard.pendingInvoiceCount.toString(),
            Icons.hourglass_top_outlined,
          ),
          _MetricCard(
            'Low stock items',
            dashboard.lowStockItemCount.toString(),
            Icons.inventory_2_outlined,
          ),
        ],
      ),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/staff/invoices/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('New invoice'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/staff/medicines'),
                    icon: const Icon(Icons.medication_outlined),
                    label: const Text('Search medicine'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class MedicineSearchScreen extends StatelessWidget {
  const MedicineSearchScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        sl<StaffSalesBloc>()..add(const MedicineSearchRequested(null)),
    child: const _MedicineSearchView(),
  );
}

class _MedicineSearchView extends StatefulWidget {
  const _MedicineSearchView();
  @override
  State<_MedicineSearchView> createState() => _MedicineSearchViewState();
}

class _MedicineSearchViewState extends State<_MedicineSearchView> {
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StaffWorkspaceShell(
    title: 'Medicine search',
    subtitle: 'Search the formulary and manage local branch inventory.',
    section: StaffWorkspaceSection.medicines,
    child: Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _search,
                    decoration: const InputDecoration(
                      labelText: 'Medicine name, SKU or batch',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _search(_searchController.text),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
            listener: _listen,
            builder: (context, state) {
              if (state is StaffSalesLoading) return const _PageLoading();
              if (state is MedicineSearchLoadSuccess) {
                return _MedicineResults(medicines: state.medicines);
              }
              return const _EmptyState(
                icon: Icons.medication_outlined,
                message: 'No medicines found.',
              );
            },
          ),
        ),
      ],
    ),
  );
  void _search(String value) =>
      context.read<StaffSalesBloc>().add(MedicineSearchRequested(value));
}

class _MedicineResults extends StatelessWidget {
  final List<MedicineDto> medicines;
  const _MedicineResults({required this.medicines});
  @override
  Widget build(BuildContext context) => Card(
    child: ListView.separated(
      itemCount: medicines.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        final low = medicine.stockStatus == 'LOW';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEAF2FF),
            child: Icon(
              Icons.medication_outlined,
              color: low ? Colors.red.shade700 : const Color(0xFF0B4D78),
            ),
          ),
          title: Text(
            medicine.medicineName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${medicine.category ?? 'General'} • ${medicine.unit}\n${medicine.availableQuantity} ${medicine.unit} in stock',
          ),
          isThreeLine: true,
          trailing: FilledButton(
            onPressed: () =>
                context.push('/staff/invoices/new', extra: medicine),
            child: const Text('Add to invoice'),
          ),
        );
      },
    ),
  );
}

class InvoiceGenerationScreen extends StatelessWidget {
  final MedicineDto? medicine;
  const InvoiceGenerationScreen({super.key, this.medicine});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<StaffSalesBloc>()..add(InvoiceDraftStarted(medicine)),
    child: _InvoiceGenerationView(medicine: medicine),
  );
}

class _InvoiceGenerationView extends StatefulWidget {
  final MedicineDto? medicine;
  const _InvoiceGenerationView({this.medicine});
  @override
  State<_InvoiceGenerationView> createState() => _InvoiceGenerationViewState();
}

class _InvoiceGenerationViewState extends State<_InvoiceGenerationView> {
  Future<void> _addMedicine() async {
    final medicine = await showMedicineSelectionDialog(context);
    if (medicine != null && mounted) {
      context.read<StaffSalesBloc>().add(InvoiceMedicineAdded(medicine));
    }
  }

  void _submit() {
    context.read<StaffSalesBloc>().add(const InvoiceSubmitted());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<StaffSalesBloc, StaffSalesState>(
        listener: (context, state) {
          if (state is InvoiceDraftValidationFailure) {
            _show(context, state.message);
          } else if (state is InvoiceSubmitFailure) {
            _show(context, state.message);
          }
          if (state is InvoiceSubmitSuccess) {
            context.go(
              '/staff/payments/process',
              extra: InvoiceSummaryDto(
                invoiceId: state.invoice.invoiceId,
                invoiceCode: state.invoice.invoiceCode,
                invoiceDate: state.invoice.invoiceDate,
                totalAmount: state.invoice.totalAmount,
                paymentStatus: state.invoice.paymentStatus,
                status: state.invoice.status,
                itemCount: state.invoice.items.length,
              ),
            );
          }
        },
        builder: (context, state) {
          final lines = _invoiceDraftLines(state);
          final total = _invoiceDraftTotal(state);
          return StaffWorkspaceShell(
            title: AppStrings.invoiceGeneration,
            subtitle: AppStrings.invoiceGenerationDescription,
            section: StaffWorkspaceSection.invoices,
            actions: [
              OutlinedButton(
                onPressed: () => context.go('/staff/invoices'),
                child: const Text(AppStrings.cancel),
              ),
            ],
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 800;
                final form = _InvoiceForm(
                  lines: lines,
                  loading: state is InvoiceSubmitting,
                  onAddMedicine: _addMedicine,
                  onQuantityChanged: (medicineId, quantity) =>
                      context.read<StaffSalesBloc>().add(
                        InvoiceMedicineQuantityChanged(medicineId, quantity),
                      ),
                  onRemove: (medicineId) => context.read<StaffSalesBloc>().add(
                    InvoiceMedicineRemoved(medicineId),
                  ),
                  onSubmit: _submit,
                );
                final summary = _InvoiceSummary(
                  itemCount: lines.length,
                  totalAmount: total,
                );
                return desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: form),
                          const SizedBox(width: 20),
                          Expanded(flex: 1, child: summary),
                        ],
                      )
                    : ListView(
                        children: [form, const SizedBox(height: 16), summary],
                      );
              },
            ),
          );
        },
      );
}

class _InvoiceForm extends StatelessWidget {
  final List<InvoiceDraftLineModel> lines;
  final bool loading;
  final VoidCallback onAddMedicine;
  final void Function(String medicineId, String quantity) onQuantityChanged;
  final ValueChanged<String> onRemove;
  final VoidCallback onSubmit;
  const _InvoiceForm({
    required this.lines,
    required this.loading,
    required this.onAddMedicine,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.invoiceMedicines,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: loading ? null : onAddMedicine,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addMedicine),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InvoiceMedicineTable(
            lines: lines,
            onQuantityChanged: onQuantityChanged,
            onRemove: onRemove,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading || lines.isEmpty ? null : onSubmit,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text(AppStrings.generateInvoice),
          ),
        ],
      ),
    ),
  );
}

class _InvoiceSummary extends StatelessWidget {
  final int itemCount;
  final double totalAmount;
  const _InvoiceSummary({required this.itemCount, required this.totalAmount});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF0B4979),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.invoiceSummary,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            const Text(AppStrings.selectedItems),
            Text(
              '$itemCount',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text(AppStrings.subtotal),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
                decimalDigits: 0,
              ).format(totalAmount),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

List<InvoiceDraftLineModel> _invoiceDraftLines(StaffSalesState state) =>
    switch (state) {
      InvoiceDraftReady(:final lines) => lines,
      InvoiceDraftValidationFailure(:final lines) => lines,
      InvoiceSubmitting(:final lines) => lines,
      InvoiceSubmitFailure(:final lines) => lines,
      _ => const <InvoiceDraftLineModel>[],
    };

double _invoiceDraftTotal(StaffSalesState state) => switch (state) {
  InvoiceDraftReady(:final total) => total,
  InvoiceDraftValidationFailure(:final total) => total,
  InvoiceSubmitting(:final total) => total,
  InvoiceSubmitFailure(:final total) => total,
  _ => 0,
};

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<StaffSalesBloc>()..add(InvoiceHistoryRequested()),
    child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
      listener: _listen,
      builder: (context, state) => StaffWorkspaceShell(
        title: 'Invoices',
        subtitle: 'Review and process financial transactions for this branch.',
        section: StaffWorkspaceSection.invoices,
        child: state is StaffSalesLoading
            ? const _PageLoading()
            : state is InvoiceHistoryLoadSuccess
            ? _InvoiceList(invoices: state.invoices)
            : const _EmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'No invoices yet.',
              ),
      ),
    ),
  );
}

class _InvoiceList extends StatelessWidget {
  final List<InvoiceSummaryDto> invoices;
  const _InvoiceList({required this.invoices});
  @override
  Widget build(BuildContext context) => Card(
    child: ListView.separated(
      itemCount: invoices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final canProcessPayment =
            invoice.paymentStatus != 'PAID' && invoice.status != 'CANCELLED';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          title: Text(
            invoice.invoiceCode,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('${invoice.invoiceDate} • ${invoice.itemCount} items'),
          trailing: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                invoice.totalAmount.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Chip(label: Text(invoice.paymentStatus)),
              OutlinedButton(
                onPressed: () =>
                    context.push('/staff/invoices/${invoice.invoiceId}'),
                child: const Text(AppStrings.viewDetails),
              ),
              if (canProcessPayment)
                FilledButton(
                  onPressed: () =>
                      context.push('/staff/payments/process', extra: invoice),
                  child: const Text(AppStrings.processPayment),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class PaymentProcessingScreen extends StatelessWidget {
  final InvoiceSummaryDto invoice;
  const PaymentProcessingScreen({super.key, required this.invoice});
  @override
  Widget build(BuildContext context) {
    if (invoice.status == 'CANCELLED') {
      return const StaffWorkspaceShell(
        title: AppStrings.cancelledInvoicePaymentTitle,
        subtitle: AppStrings.cancelledInvoicePaymentMessage,
        section: StaffWorkspaceSection.payments,
        child: _EmptyState(
          icon: Icons.block_outlined,
          message: AppStrings.cancelledInvoicePaymentMessage,
        ),
      );
    }

    return BlocProvider(
      create: (_) => sl<StaffSalesBloc>(),
      child: _PaymentProcessingView(invoice: invoice),
    );
  }
}

class _PaymentProcessingView extends StatefulWidget {
  final InvoiceSummaryDto invoice;
  const _PaymentProcessingView({required this.invoice});
  @override
  State<_PaymentProcessingView> createState() => _PaymentProcessingViewState();
}

class _PaymentProcessingViewState extends State<_PaymentProcessingView> {
  String _method = 'CASH';
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<StaffSalesBloc, StaffSalesState>(
    listener: (context, state) {
      _listen(context, state);
      if (state is PaymentSubmitSuccess &&
          state.payment.paymentStatus == 'PAID') {
        context.go('/staff/payments');
      }
      if (state is PaymentStatusLoadSuccess &&
          state.payment.paymentStatus == 'PAID') {
        context.go('/staff/payments');
      }
    },
    builder: (context, state) => StaffWorkspaceShell(
      title: 'Checkout',
      subtitle: 'Confirm the payment method for this invoice.',
      section: StaffWorkspaceSection.payments,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final methods = ['CASH', 'QR'];
          final selection = Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Payment method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
                    groupValue: _method,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _method = value);
                      }
                    },
                    child: Column(
                      children: methods
                          .map(
                            (method) => RadioListTile<String>(
                              value: method,
                              title: Text(
                                method == 'CASH'
                                    ? 'Cash payment'
                                    : AppStrings.qrPayment,
                              ),
                              subtitle: Text(
                                method == 'CASH'
                                    ? 'Physical currency at terminal'
                                    : AppStrings.qrPaymentDescription,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: state is StaffSalesLoading
                        ? null
                        : () => context.read<StaffSalesBloc>().add(
                            PaymentSubmitted(widget.invoice.invoiceId, _method),
                          ),
                    icon: const Icon(Icons.lock_outline),
                    label: Text(
                      _method == 'QR'
                          ? AppStrings.generatePaymentQr
                          : 'Confirm payment',
                    ),
                  ),
                  if (_qrPaymentFrom(state) case final payment?)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PaymentQrCard(
                        payment: payment,
                        isRefreshing: state is PaymentStatusRefreshInProgress,
                        onRefresh: () => context.read<StaffSalesBloc>().add(
                          PaymentStatusRequested(payment),
                        ),
                        onRegenerate: () => context.read<StaffSalesBloc>().add(
                          PaymentSubmitted(widget.invoice.invoiceId, 'QR'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
          final invoiceCard = Card(
            color: const Color(0xFF0B4979),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total payable'),
                    const SizedBox(height: 12),
                    Text(
                      widget.invoice.totalAmount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Invoice ${widget.invoice.invoiceCode}'),
                    Text('${widget.invoice.itemCount} items'),
                  ],
                ),
              ),
            ),
          );
          return constraints.maxWidth >= 760
              ? SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: selection),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: invoiceCard),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    invoiceCard,
                    const SizedBox(height: 16),
                    selection,
                  ],
                );
        },
      ),
    ),
  );

  PaymentDto? _qrPaymentFrom(StaffSalesState state) {
    if (state is PaymentSubmitSuccess && state.payment.paymentMethod == 'QR') {
      return state.payment;
    }
    if (state is PaymentStatusLoadSuccess &&
        state.payment.paymentMethod == 'QR') {
      return state.payment;
    }
    if (state is PaymentStatusRefreshInProgress &&
        state.payment.paymentMethod == 'QR') {
      return state.payment;
    }
    if (state is PaymentStatusRefreshFailure &&
        state.payment.paymentMethod == 'QR') {
      return state.payment;
    }
    return null;
  }
}

class PaymentTransactionsScreen extends StatelessWidget {
  const PaymentTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<StaffSalesBloc>()..add(PaymentTransactionsRequested()),
    child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
      listener: _listen,
      builder: (context, state) => StaffWorkspaceShell(
        title: 'Payment history',
        subtitle: 'View completed transactions for this branch.',
        section: StaffWorkspaceSection.payments,
        child: state is StaffSalesLoading
            ? const _PageLoading()
            : state is PaymentTransactionsLoadSuccess
            ? Card(
                child: ListView.separated(
                  itemCount: state.payments.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final payment = state.payments[index];
                    return ListTile(
                      title: Text(payment.invoiceCode),
                      subtitle: Text(
                        '${payment.paymentMethod} • ${payment.paymentStatus}',
                      ),
                      trailing: Text(
                        payment.amount.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    );
                  },
                ),
              )
            : const _EmptyState(
                icon: Icons.payments_outlined,
                message: 'No payment transactions yet.',
              ),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _MetricCard(this.title, this.value, this.icon);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0B4D78)),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    ),
  );
}

class _PageLoading extends StatelessWidget {
  const _PageLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 42, color: const Color(0xFF607083)),
        const SizedBox(height: 12),
        Text(message),
      ],
    ),
  );
}

void _listen(BuildContext context, StaffSalesState state) {
  if (state is StaffSalesLoadFailure) _show(context, state.message);
  if (state is PaymentStatusRefreshFailure) _show(context, state.message);
}

void _show(BuildContext context, String message) =>
    showAppErrorSnackBar(context, message: message);
