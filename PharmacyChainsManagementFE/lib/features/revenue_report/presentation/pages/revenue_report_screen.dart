import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/revenue_report_bloc.dart';
import '../bloc/revenue_report_event.dart';
import '../bloc/revenue_report_state.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/revenue_summary_card.dart';
import '../widgets/shimmer_loading.dart';
import '../../../../core/app_logger.dart';

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
      appBar: AppBar(
        title: const Text('Revenue Report'),
        actions: [
          BlocBuilder<RevenueReportBloc, RevenueReportState>(
            builder: (context, state) {
              if (state is RevenueReportLoaded) {
                return Semantics(
                  label: 'Share revenue report',
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share Report',
                    onPressed: () => _shareReport(state),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              BlocBuilder<RevenueReportBloc, RevenueReportState>(
                builder: (context, state) {
                  if (state is RevenueReportInitial || state is RevenueReportLoading) {
                    return const RevenueShimmerLoading();
                  } else if (state is RevenueReportLoaded) {
                    return Column(
                      children: [
                        RevenueSummaryCard(
                          totalRevenue: state.report.grossRevenue,
                          totalOrders: state.report.items.length, // approximation
                        ),
                        const SizedBox(height: 24),
                        RevenueChart(dailyData: state.report.items),
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
    );
  }
}
