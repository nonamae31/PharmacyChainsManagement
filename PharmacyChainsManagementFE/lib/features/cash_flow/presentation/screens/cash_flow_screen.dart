import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../injection_container.dart';
import '../bloc/cash_flow_bloc.dart';
import '../bloc/cash_flow_event.dart';
import '../bloc/cash_flow_state.dart';
import '../../domain/entities/cash_flow_statistics_entity.dart';

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CashFlowBloc>(),
      child: const CashFlowView(),
    );
  }
}

class CashFlowView extends StatefulWidget {
  const CashFlowView({super.key});

  @override
  State<CashFlowView> createState() => _CashFlowViewState();
}

class _CashFlowViewState extends State<CashFlowView> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final TextEditingController _branchIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date cannot be after end date')),
      );
      return;
    }
    context.read<CashFlowBloc>().add(
          FetchCashFlowEvent(
            startDate: _startDate.toIso8601String(),
            endDate: _endDate.toIso8601String(),
            branchId: _branchIdController.text.isNotEmpty ? _branchIdController.text : null,
          ),
        );
  }

  void _setPreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      if (preset == 'Tuần này') {
        _startDate = now.subtract(Duration(days: now.weekday - 1));
      } else if (preset == 'Tháng này') {
        _startDate = DateTime(now.year, now.month, 1);
      } else if (preset == 'YTD') {
        _startDate = DateTime(now.year, 1, 1);
      }
    });
    _fetchData();
  }

  Future<void> _exportAndShare(CashFlowStatisticsEntity data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Cash Flow Report', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Total Inflow: \u0024${data.totalInflow.toStringAsFixed(2)}'),
            pw.Text('Total Outflow: \u0024${data.totalOutflow.toStringAsFixed(2)}'),
            pw.Text('Net Cash Flow: \u0024${data.netCashFlow.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/cash_flow_report.pdf');
    await file.writeAsBytes(await pdf.save());

    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Cash Flow Report from ${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}',
    );
  }

  void _showDetailsBottomSheet(String title, double amount, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Amount: \u0024${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text('More detailed transactions can be listed here.'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Semantics(
        label: '$title is \u0024${amount.toStringAsFixed(2)}',
        child: InkWell(
          onTap: () => _showDetailsBottomSheet(title, amount, color),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Column(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    '\u0024${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<CashFlowDailyDataEntity> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No chart data available')),
      );
    }
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.inflow)).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.green.withAlpha(50)), // using withAlpha instead of withOpacity
            ),
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.outflow)).toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.red.withAlpha(50)), // using withAlpha instead of withOpacity
            ),
          ],
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow'),
        actions: [
          BlocBuilder<CashFlowBloc, CashFlowState>(
            builder: (context, state) {
              if (state is CashFlowLoaded) {
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _exportAndShare(state.cashFlow),
                  tooltip: 'Export & Share',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Filter
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                        _fetchData();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()),
                      child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                        _fetchData();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date', border: OutlineInputBorder()),
                      child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _branchIdController,
                    decoration: const InputDecoration(
                      labelText: 'Branch ID (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _fetchData(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tuần này', 'Tháng này', 'YTD'].map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(preset),
                      onPressed: () => _setPreset(preset),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: BlocBuilder<CashFlowBloc, CashFlowState>(
                builder: (context, state) {
                  if (state is CashFlowInitial || state is CashFlowLoading) {
                    return _buildShimmer();
                  } else if (state is CashFlowError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  } else if (state is CashFlowLoaded) {
                    final data = state.cashFlow;
                    if (data.totalInflow == 0 && data.totalOutflow == 0) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No data available for the selected period.'),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _fetchData(),
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              _buildSummaryCard(
                                title: 'Total Inflow',
                                amount: data.totalInflow,
                                color: Colors.green,
                                icon: Icons.arrow_upward,
                              ),
                              _buildSummaryCard(
                                title: 'Total Outflow',
                                amount: data.totalOutflow,
                                color: Colors.red,
                                icon: Icons.arrow_downward,
                              ),
                              _buildSummaryCard(
                                title: 'Net Cash Flow',
                                amount: data.netCashFlow,
                                color: data.netCashFlow >= 0 ? Colors.blue : Colors.orange,
                                icon: data.netCashFlow >= 0 ? Icons.account_balance_wallet : Icons.money_off,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Cash Flow Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildChart(data.dailyData),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
