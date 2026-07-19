import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/revenue_report_bloc.dart';
import '../bloc/revenue_report_event.dart';
import '../bloc/revenue_report_state.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/revenue_mix_chart.dart';
import '../widgets/revenue_metric_cards.dart';
import '../widgets/branch_performance_table.dart';
import '../widgets/shimmer_loading.dart';
import '../../../../core/app_logger.dart';
import '../../../finance/presentation/pages/financial_export_screen.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  void _fetchReport() {
    context.read<RevenueReportBloc>().add(
          FetchRevenueReportEvent(startDate: startDate, endDate: endDate),
        );
  }

  Future<void> _onRefresh() async {
    _fetchReport();
    await context.read<RevenueReportBloc>().stream.firstWhere((state) => state is! RevenueReportLoading);
  }

  void _shareReport(RevenueReportLoaded state) {
    try {
      final text = 'Revenue Report summary:\n'
          'Total Revenue: \$${state.report.grossRevenue.toStringAsFixed(2)}\n';
      // ignore: deprecated_member_use
      Share.share(text, subject: 'Revenue Report');
      AppLogger.info('Shared revenue report successfully');
    } catch (e) {
      AppLogger.error('Failed to share report', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light greyish blue background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                BlocBuilder<RevenueReportBloc, RevenueReportState>(
                  builder: (context, state) {
                    if (state is RevenueReportInitial || state is RevenueReportLoading) {
                      return const RevenueShimmerLoading();
                    } else if (state is RevenueReportLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RevenueMetricCards(
                            totalRevenue: state.report.grossRevenue,
                            totalRevenueGrowth: state.report.grossRevenueGrowth,
                            avgRevenue: state.report.avgRevenuePerBranch,
                            avgRevenueGrowth: state.report.avgRevenueGrowth,
                            topBranchName: state.report.topBranchName,
                            topBranchRevenue: state.report.topBranchRevenue,
                            forecastQ4: state.report.forecastQ4,
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 800) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    RevenueChart(dailyData: state.report.items),
                                    const SizedBox(height: 24),
                                    RevenueMixChart(data: state.report.revenueMix),
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: RevenueChart(dailyData: state.report.items),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 1,
                                    child: RevenueMixChart(data: state.report.revenueMix),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          BranchPerformanceTable(data: state.report.branchPerformance),
                        ],
                      );
                    } else if (state is RevenueReportError) {
                      return Semantics(
                        label: 'Error message: ${state.message}',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Revenue Report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Financial performance summary across all operational branches.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Last 30 Days',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final isDesktop = MediaQuery.of(context).size.width > 800;
                if (isDesktop) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
                          child: const FinancialExportScreen(),
                        ),
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FinancialExportScreen()),
                  );
                }
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export Full Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
