import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../control/staff_sales_bloc.dart';
import '../control/staff_sales_event.dart';
import '../control/staff_sales_state.dart';
import '../entity/staff_sales_dto.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});
  @override Widget build(BuildContext context) => BlocProvider(create: (_) => sl<StaffSalesBloc>()..add(StaffDashboardRequested()), child: const _DashboardView());
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();
  @override Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Staff Dashboard')),
        body: BlocConsumer<StaffSalesBloc, StaffSalesState>(
          listener: _listen,
          builder: (context, state) {
            if (state is StaffDashboardLoadSuccess) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MetricCard('Doanh thu hôm nay', state.dashboard.todayRevenue.toStringAsFixed(0)),
                  _MetricCard('Hóa đơn hôm nay', state.dashboard.todayInvoiceCount.toString()),
                  _MetricCard('Chờ thanh toán', state.dashboard.pendingInvoiceCount.toString()),
                  _MetricCard('Cảnh báo tồn kho', state.dashboard.lowStockItemCount.toString()),
                  _MetricCard('Ca làm việc', state.dashboard.shiftLabel),
                  const SizedBox(height: 16),
                  _NavigationTile('Tìm thuốc', Icons.medication_outlined, () => context.push('/staff/medicines')),
                  _NavigationTile('Tạo hóa đơn', Icons.receipt_long_outlined, () => context.push('/staff/invoices/new')),
                  _NavigationTile('Lịch sử hóa đơn', Icons.history_outlined, () => context.push('/staff/invoices')),
                  _NavigationTile('Lịch sử thanh toán', Icons.payments_outlined, () => context.push('/staff/payments')),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
}

class MedicineSearchScreen extends StatelessWidget {
  const MedicineSearchScreen({super.key});
  @override Widget build(BuildContext context) => BlocProvider(create: (_) => sl<StaffSalesBloc>()..add(const MedicineSearchRequested(null)), child: const _MedicineSearchView());
}

class _MedicineSearchView extends StatefulWidget { const _MedicineSearchView(); @override State<_MedicineSearchView> createState() => _MedicineSearchViewState(); }
class _MedicineSearchViewState extends State<_MedicineSearchView> {
  final _searchController = TextEditingController();
  @override void dispose() { _searchController.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Tìm thuốc')), body: Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _searchController, decoration: InputDecoration(labelText: 'Tên thuốc hoặc mã lô', suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => context.read<StaffSalesBloc>().add(MedicineSearchRequested(_searchController.text)))), onSubmitted: (value) => context.read<StaffSalesBloc>().add(MedicineSearchRequested(value)))),
    Expanded(
      child: BlocConsumer<StaffSalesBloc, StaffSalesState>(
        listener: _listen,
        builder: (context, state) {
          if (state is StaffSalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MedicineSearchLoadSuccess) {
            return ListView.builder(
              itemCount: state.medicines.length,
              itemBuilder: (context, index) => _MedicineTile(medicine: state.medicines[index]),
            );
          }
          return const Center(child: Text('Chưa có dữ liệu thuốc'));
        },
      ),
    )
  ]));
}

class _MedicineTile extends StatelessWidget {
  final MedicineDto medicine; const _MedicineTile({required this.medicine});
  @override Widget build(BuildContext context) => ListTile(title: Text(medicine.medicineName), subtitle: Text('${medicine.availableQuantity} ${medicine.unit} • ${medicine.stockStatus}'), trailing: FilledButton(onPressed: () => context.push('/staff/invoices/new', extra: medicine), child: const Text('Thêm hóa đơn')));
}

class InvoiceGenerationScreen extends StatelessWidget {
  final MedicineDto? medicine; const InvoiceGenerationScreen({super.key, this.medicine});
  @override Widget build(BuildContext context) => BlocProvider(create: (_) => sl<StaffSalesBloc>(), child: _InvoiceGenerationView(medicine: medicine));
}

class _InvoiceGenerationView extends StatefulWidget { final MedicineDto? medicine; const _InvoiceGenerationView({this.medicine}); @override State<_InvoiceGenerationView> createState() => _InvoiceGenerationViewState(); }
class _InvoiceGenerationViewState extends State<_InvoiceGenerationView> {
  final _medicineIdController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _medicineIdController.text = widget.medicine?.medicineId ?? '';
  }

  @override
  void dispose() {
    _medicineIdController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = int.tryParse(_quantityController.text);
    if (_medicineIdController.text.isEmpty || quantity == null || quantity < 1) {
      _show(context, 'Nhập thuốc và số lượng hợp lệ.');
      return;
    }
    context.read<StaffSalesBloc>().add(InvoiceSubmitted([
      InvoiceLineRequestDto(medicineId: _medicineIdController.text, quantity: quantity)
    ]));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tạo hóa đơn')),
        body: BlocConsumer<StaffSalesBloc, StaffSalesState>(
          listener: (context, state) {
            _listen(context, state);
            if (state is InvoiceSubmitSuccess) {
              context.go(
                '/staff/payments/process',
                extra: InvoiceSummaryDto(
                  invoiceId: state.invoice.invoiceId,
                  invoiceCode: state.invoice.invoiceCode,
                  invoiceDate: state.invoice.invoiceDate,
                  totalAmount: state.invoice.totalAmount,
                  paymentStatus: state.invoice.paymentStatus,
                  itemCount: state.invoice.items.length,
                ),
              );
            }
          },
          builder: (context, state) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.medicine != null)
                  Text(widget.medicine!.medicineName, style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _medicineIdController,
                  decoration: const InputDecoration(labelText: 'Medicine ID'),
                  readOnly: widget.medicine != null,
                ),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state is StaffSalesLoading ? null : _submit,
                  child: const Text('Tạo hóa đơn'),
                ),
              ],
            ),
          ),
        ),
      );
}

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<StaffSalesBloc>()..add(InvoiceHistoryRequested()),
        child: Scaffold(
          appBar: AppBar(title: const Text('Lịch sử hóa đơn')),
          body: BlocConsumer<StaffSalesBloc, StaffSalesState>(
            listener: _listen,
            builder: (context, state) {
              if (state is StaffSalesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is InvoiceHistoryLoadSuccess) {
                return ListView.builder(
                  itemCount: state.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = state.invoices[index];
                    return ListTile(
                      title: Text(invoice.invoiceCode),
                      subtitle: Text('${invoice.totalAmount.toStringAsFixed(0)} • ${invoice.paymentStatus}'),
                      trailing: invoice.paymentStatus == 'PAID'
                          ? null
                          : FilledButton(
                              onPressed: () => context.push('/staff/payments/process', extra: invoice),
                              child: const Text('Thanh toán'),
                            ),
                    );
                  },
                );
              }
              return const Center(child: Text('Chưa có hóa đơn'));
            },
          ),
        ),
      );
}

class PaymentProcessingScreen extends StatelessWidget {
  final InvoiceSummaryDto invoice;
  const PaymentProcessingScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<StaffSalesBloc>(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Thanh toán')),
          body: BlocConsumer<StaffSalesBloc, StaffSalesState>(
            listener: (context, state) {
              _listen(context, state);
              if (state is PaymentSubmitSuccess) {
                context.go('/staff/payments');
              }
            },
            builder: (context, state) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(invoice.invoiceCode, style: Theme.of(context).textTheme.titleLarge),
                  Text('Tổng tiền: ${invoice.totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 24),
                  for (final method in const ['CASH', 'CARD', 'QR'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FilledButton(
                        onPressed: state is StaffSalesLoading
                            ? null
                            : () => context.read<StaffSalesBloc>().add(PaymentSubmitted(invoice.invoiceId, method)),
                        child: Text(method),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class PaymentTransactionsScreen extends StatelessWidget {
  const PaymentTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<StaffSalesBloc>()..add(PaymentTransactionsRequested()),
        child: Scaffold(
          appBar: AppBar(title: const Text('Lịch sử thanh toán')),
          body: BlocConsumer<StaffSalesBloc, StaffSalesState>(
            listener: _listen,
            builder: (context, state) {
              if (state is StaffSalesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PaymentTransactionsLoadSuccess) {
                return ListView.builder(
                  itemCount: state.payments.length,
                  itemBuilder: (context, index) {
                    final payment = state.payments[index];
                    return ListTile(
                      title: Text(payment.invoiceCode),
                      subtitle: Text('${payment.paymentMethod} • ${payment.paymentStatus}'),
                      trailing: Text(payment.amount.toStringAsFixed(0)),
                    );
                  },
                );
              }
              return const Center(child: Text('Chưa có giao dịch'));
            },
          ),
        ),
      );
}

class _MetricCard extends StatelessWidget { final String title; final String value; const _MetricCard(this.title, this.value); @override Widget build(BuildContext context) => Card(child: ListTile(title: Text(title), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium))); }
class _NavigationTile extends StatelessWidget { final String title; final IconData icon; final VoidCallback onTap; const _NavigationTile(this.title, this.icon, this.onTap); @override Widget build(BuildContext context) => Card(child: ListTile(title: Text(title), leading: Icon(icon), trailing: const Icon(Icons.chevron_right), onTap: onTap)); }
void _listen(BuildContext context, StaffSalesState state) {
  if (state is StaffSalesLoadFailure) {
    _show(context, state.message);
  }
}
void _show(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
