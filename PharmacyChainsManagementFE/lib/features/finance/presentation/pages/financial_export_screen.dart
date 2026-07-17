import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/export_helper.dart';
import '../../../../core/widgets/network_connectivity_guard.dart';
import '../../data/models/export_criteria_model.dart';
import '../cubit/financial_export_cubit.dart';
import '../cubit/financial_export_state.dart';
import '../widgets/lottie_loading_dialog.dart';

class FinancialExportScreen extends StatelessWidget {
  const FinancialExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialExportCubit>(
      create: (context) => GetIt.instance<FinancialExportCubit>(),
      child: NetworkConnectivityGuard(
        child: BlocListener<FinancialExportCubit, FinancialExportState>(
          listener: (context, state) {
            if (state is FinancialExportLoading) {
              LottieLoadingDialog.show(context);
            } else if (state is FinancialExportSuccess) {
              LottieLoadingDialog.hide(context);
              Fluttertoast.showToast(
                msg: 'Export successful!',
                backgroundColor: Colors.green,
              );
              final format = _CurrentExportCriteria.format;
              final fileName =
                  'Financial_Report_${DateTime.now().millisecondsSinceEpoch}.$format';
              ExportHelper.saveAndShareFile(state.fileBytes, fileName);
            } else if (state is FinancialExportError) {
              LottieLoadingDialog.hide(context);
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Export Financial Reports')),
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return const Center(
                    child: SizedBox(
                      width: 600,
                      child: Card(
                        margin: EdgeInsets.all(24.0),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: ExportFormWidget(),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Open Export Form'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (bottomSheetContext) {
                            return BlocProvider.value(
                              value: context.read<FinancialExportCubit>(),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    bottomSheetContext,
                                  ).viewInsets.bottom,
                                ),
                                child: const ExportFormWidget(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentExportCriteria {
  static String format = 'pdf'; // Global temporary state for file extension
}

class ExportFormWidget extends StatefulWidget {
  const ExportFormWidget({super.key});

  @override
  State<ExportFormWidget> createState() => _ExportFormWidgetState();
}

class _ExportFormWidgetState extends State<ExportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _branchId = '';
  String _format = 'pdf';
  DateTimeRange? _dateRange;

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _dateRange != null) {
      _formKey.currentState!.save();
      _CurrentExportCriteria.format = _format.toLowerCase();

      final criteria = ExportCriteriaModel(
        branchId: _branchId,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        format: _format,
      );
      context.read<FinancialExportCubit>().exportReport(criteria);
    } else if (_dateRange == null) {
      Fluttertoast.showToast(msg: 'Please select a date range');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Export Criteria',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Branch ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
              onSaved: (value) => _branchId = value!,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Range',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dateRange == null
                      ? 'Select Date Range'
                      : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _format,
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'excel', child: Text('Excel')),
                DropdownMenuItem(value: 'csv', child: Text('CSV')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _format = val);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: NetworkConnectivityGuard.isOffline(context)
                  ? null
                  : _onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Export Report',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
