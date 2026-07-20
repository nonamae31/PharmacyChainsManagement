import 'package:universal_io/io.dart';
import 'dart:math' as math;
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
import '../../domain/entities/branch_entity.dart';

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
  String? _selectedBranchId;
  List<BranchEntity> _cachedBranches = [];

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
            startDate: DateFormat('yyyy-MM-dd').format(_startDate),
            endDate: DateFormat('yyyy-MM-dd').format(_endDate),
            branchId: _selectedBranchId,
          ),
        );
  }

  void _setPreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      if (preset == 'This Week') {
        _startDate = now.subtract(Duration(days: now.weekday - 1));
      } else if (preset == 'This Month') {
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
    
    double getLogValue(double value) {
      if (value <= 0) return 0;
      return math.log(value + 1) / math.ln10; // Log base 10
    }
    
    double maxLogY = 0;
    for (var d in data) {
      final inLog = getLogValue(d.inflow);
      final outLog = getLogValue(d.outflow);
      if (inLog > maxLogY) maxLogY = inLog;
      if (outLog > maxLogY) maxLogY = outLog;
    }
    
    if (maxLogY == 0) {
      maxLogY = 1;
    } else {
      maxLogY = maxLogY * 1.5; // 50% padding at the top to prevent curve clipping
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.only(left: 16, right: 32, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          minX: -1, // Horizontal padding left
          maxX: data.isNotEmpty ? data.length.toDouble() : 0, // Horizontal padding right
          minY: 0,
          maxY: maxLogY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final isGreen = touchedSpot.barIndex == 0;
                  final int index = touchedSpot.x.round();
                  if (index < 0 || index >= data.length) return null;
                  
                  final originalValue = isGreen ? data[index].inflow : data[index].outflow;
                  final formatter = NumberFormat.currency(symbol: '\$');
                  
                  return LineTooltipItem(
                    '${isGreen ? 'Inflow' : 'Outflow'}\n${formatter.format(originalValue)}',
                    TextStyle(color: isGreen ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), getLogValue(e.value.inflow))).toList(),
              isCurved: true,
              preventCurveOverShooting: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.green.withAlpha(50)),
            ),
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), getLogValue(e.value.outflow))).toList(),
              isCurved: true,
              preventCurveOverShooting: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.red.withAlpha(50)),
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
                  child: BlocBuilder<CashFlowBloc, CashFlowState>(
                    builder: (context, state) {
                      if (state is CashFlowLoaded) {
                        final Map<String, BranchEntity> uniqueBranchesMap = {};
                        for (var branch in state.branches) {
                          uniqueBranchesMap[branch.id] = branch;
                        }
                        _cachedBranches = uniqueBranchesMap.values.toList();
                      }

                      List<DropdownMenuItem<String>> items = [
                        const DropdownMenuItem(value: null, child: Text('All Branches')),
                      ];
                        
                      items.addAll(_cachedBranches.map((b) => DropdownMenuItem<String>(
                        value: b.id,
                        child: Text(b.name),
                      )));
                      
                      String? validValue = _selectedBranchId;
                      if (validValue != null && !items.any((item) => item.value == validValue)) {
                        validValue = null;
                      }

                      return DropdownButtonFormField<String>(
                        value: validValue,
                        decoration: const InputDecoration(
                          labelText: 'Branch',
                          border: OutlineInputBorder(),
                        ),
                        items: items,
                        onChanged: (val) {
                          setState(() {
                            _selectedBranchId = val;
                          });
                          _fetchData();
                        },
                      );
                    },
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
                children: ['This Week', 'This Month', 'YTD'].map((preset) {
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
                          _buildLiquidityForecastChart(data.liquidityForecasts),
                          _buildRecentTransactions(data.recentTransactions),
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

  Widget _buildLiquidityForecastChart(List<LiquidityForecastEntity> forecasts) {
    if (forecasts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Liquidity Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: forecasts.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(toY: e.value.projectedInflow, color: Colors.green, width: 15),
                    BarChartRodData(toY: e.value.projectedOutflow, color: Colors.red, width: 15),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() >= 0 && value.toInt() < forecasts.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(forecasts[value.toInt()].month, style: const TextStyle(fontSize: 12)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildRecentTransactions(List<RecentTransactionEntity> transactions) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...transactions.map((t) {
          final isWeIn = t.type == 'Inflow';
          return ListTile(
            leading: Icon(
              isWeIn ? Icons.arrow_upward : Icons.arrow_downward,
              color: isWeIn ? Colors.green : Colors.red,
            ),
            title: Text(t.description),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(t.date)),
            trailing: Text(
              '${isWeIn ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isWeIn ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }),
      ],
    );
  }
}
