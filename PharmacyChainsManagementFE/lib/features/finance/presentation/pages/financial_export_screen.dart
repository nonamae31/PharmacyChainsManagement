import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';

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
                final isDesktop = constraints.maxWidth > 800;
                if (isDesktop) {
                  return const Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.0),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: ExportFormWidget(isDesktop: true),
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (bottomSheetContext) {
                            return BlocProvider.value(
                              value: context.read<FinancialExportCubit>(),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                ),
                                child: const ExportFormWidget(isDesktop: false),
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
  final bool isDesktop;
  const ExportFormWidget({super.key, this.isDesktop = false});

  @override
  State<ExportFormWidget> createState() => _ExportFormWidgetState();
}

class _ExportFormWidgetState extends State<ExportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _branchId;
  String _format = 'pdf';
  DateTimeRange? _dateRange;
  
  List<Map<String, dynamic>> _branches = [];
  bool _isLoadingBranches = true;

  bool get _isComplete => _branchId != null && _dateRange != null;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final dio = ApiClient.createDio();
      final response = await dio.get('/api/branches');
      if (response.statusCode == 200) {
        setState(() {
          _branches = List<Map<String, dynamic>>.from(response.data);
          _branches.insert(0, {'id': '', 'name': 'All Branches'});
          _isLoadingBranches = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBranches = false;
      });
    }
  }

  void _selectDateRange() async {
    DateTimeRange? picked;
    if (widget.isDesktop) {
      picked = await showDialog<DateTimeRange>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
            child: Theme(
              data: Theme.of(context).copyWith(
                appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
              ),
              child: DateRangePickerDialog(
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: _dateRange,
              ),
            ),
          ),
        ),
      );
    } else {
      picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDateRange: _dateRange,
      );
    }

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
        branchId: _branchId!,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        format: _format,
      );
      context.read<FinancialExportCubit>().exportReport(criteria);
    } else if (_dateRange == null) {
      Fluttertoast.showToast(msg: 'Please select a date range');
    }
  }

  Widget _buildForm() {
    return Form(
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
          _isLoadingBranches 
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Branch',
              border: OutlineInputBorder(),
            ),
            initialValue: _branchId,
            items: _branches.map((b) => DropdownMenuItem<String>(
              value: b['id'] == '' ? '00000000-0000-0000-0000-000000000000' : b['id'].toString(),
              child: Text(b['name'].toString()),
            )).toList(),
            onChanged: (val) {
              setState(() => _branchId = val);
            },
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
              DropdownMenuItem(value: 'csv', child: Text('CSV')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _format = val);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export Report', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = _isComplete
        ? ReportPreviewCard(
            branchId: _branchId!,
            dateRange: _dateRange!,
            format: _format,
          )
        : const SizedBox();

    if (widget.isDesktop) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildForm()),
            if (_isComplete) const SizedBox(width: 32),
            if (_isComplete) Expanded(flex: 1, child: previewContent),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildForm(),
            if (_isComplete) const SizedBox(height: 24),
            if (_isComplete) previewContent,
            const SizedBox(height: 24),
          ],
        ),
      );
    }
  }
}

class ReportPreviewCard extends StatefulWidget {
  final String branchId;
  final DateTimeRange dateRange;
  final String format;

  const ReportPreviewCard({
    super.key,
    required this.branchId,
    required this.dateRange,
    required this.format,
  });

  @override
  State<ReportPreviewCard> createState() => _ReportPreviewCardState();
}

class _ReportPreviewCardState extends State<ReportPreviewCard> {
  bool _isLoading = true;
  double? _grossRevenue;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPreview();
  }

  @override
  void didUpdateWidget(covariant ReportPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId || oldWidget.dateRange != widget.dateRange) {
      _fetchPreview();
    }
  }

  Future<void> _fetchPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ApiClient.createDio();
      final response = await dio.post('/api/reports/revenue', data: {
        'fromDate': DateFormat('yyyy-MM-dd').format(widget.dateRange.start),
        'toDate': DateFormat('yyyy-MM-dd').format(widget.dateRange.end),
        'branchId': widget.branchId,
      });

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        setState(() {
          _grossRevenue = (response.data['data']['grossRevenue'] as num?)?.toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load preview';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading preview';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Report Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Branch: ${widget.branchId == '00000000-0000-0000-0000-000000000000' ? 'All Branches' : widget.branchId}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Period: ${DateFormat('MMM dd').format(widget.dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(widget.dateRange.end)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('Format: ${widget.format.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Center(
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : _error != null 
                    ? Text(_error!, style: const TextStyle(color: Colors.red))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_money, size: 48, color: Colors.teal),
                          const SizedBox(height: 8),
                          const Text('Total Revenue Preview', style: TextStyle(color: Colors.black54)),
                          Text(
                            '\$${_grossRevenue?.toStringAsFixed(2) ?? "0.00"}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
