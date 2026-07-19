import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/platform/csv_file_exporter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_empty_state.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/business_admin_bloc.dart';
import '../control/business_admin_event.dart';
import '../control/business_admin_state.dart';
import '../entity/business_analysis_report_dto.dart';

class BusinessAnalysisReportScreen extends StatefulWidget {
  const BusinessAnalysisReportScreen({super.key});

  @override
  State<BusinessAnalysisReportScreen> createState() =>
      _BusinessAnalysisReportScreenState();
}

class _BusinessAnalysisReportScreenState
    extends State<BusinessAnalysisReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  final _branchSearchController = TextEditingController();
  String _viewMode = 'detailed';

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = DateTime(_toDate.year, _toDate.month, 1);
    _fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessAdminBloc, BusinessAdminState>(
      listener: (context, state) {
        if (state is BusinessAdminLoadFailure) {
          showAppErrorDialog(context, message: state.message);
        }
      },
      builder: (context, state) {
        if (state is BusinessAdminLoading) return const AppLoadingIndicator();
        if (state is BusinessAnalysisReportLoadSuccess) {
          return _ReportContent(
            report: state.report,
            fromDate: _fromDate,
            toDate: _toDate,
            branchSearchController: _branchSearchController,
            viewMode: _viewMode,
            onDateRangePressed: _pickDateRange,
            onViewModeChanged: _changeViewMode,
            onSearchSubmitted: _searchBranch,
            onRefresh: _fetchReport,
          );
        }
        return AppEmptyState(onRetry: _fetchReport);
      },
    );
  }

  void _fetchReport() {
    context.read<BusinessAdminBloc>().add(
      BusinessAnalysisReportFetchRequested(
        BusinessAnalysisFilterDto(
          fromDate: _fromDate,
          toDate: _toDate,
          branchSearch: _branchSearchController.text.trim().isEmpty
              ? null
              : _branchSearchController.text.trim(),
          viewMode: _viewMode,
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );
    if (selected == null) return;
    setState(() {
      _fromDate = selected.start;
      _toDate = selected.end;
    });
    _fetchReport();
  }

  void _changeViewMode(String value) {
    if (_viewMode == value) return;
    setState(() => _viewMode = value);
    _fetchReport();
  }

  void _searchBranch(String value) {
    _branchSearchController.text = value.trim();
    _fetchReport();
  }

  @override
  void dispose() {
    _branchSearchController.dispose();
    super.dispose();
  }
}

class _ReportContent extends StatelessWidget {
  final BusinessAnalysisReportDto report;
  final DateTime fromDate;
  final DateTime toDate;
  final TextEditingController branchSearchController;
  final String viewMode;
  final VoidCallback onDateRangePressed;
  final ValueChanged<String> onViewModeChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onRefresh;

  const _ReportContent({
    required this.report,
    required this.fromDate,
    required this.toDate,
    required this.branchSearchController,
    required this.viewMode,
    required this.onDateRangePressed,
    required this.onViewModeChanged,
    required this.onSearchSubmitted,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 920;
        return DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xFFF4F7FA)),
          child: ListView(
            padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.md),
            children: [
              _ReportHeader(
                fromDate: fromDate,
                toDate: toDate,
                viewMode: viewMode,
                report: report,
                onDateRangePressed: onDateRangePressed,
                onViewModeChanged: onViewModeChanged,
                onRefresh: onRefresh,
                isDesktop: isDesktop,
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricGrid(report: report, isDesktop: isDesktop),
              const SizedBox(height: AppSpacing.lg),
              if (viewMode == 'detailed') ...[
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _RevenuePanel(report: report)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 3, child: _CategoryPanel(report: report)),
                    ],
                  )
                else ...[
                  _RevenuePanel(report: report),
                  const SizedBox(height: AppSpacing.lg),
                  _CategoryPanel(report: report),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
              if (isDesktop && viewMode == 'detailed')
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TopBranchesPanel(report: report)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _RegionalSummaryPanel(
                        report: report,
                        branchSearchController: branchSearchController,
                        onSearchSubmitted: onSearchSubmitted,
                      ),
                    ),
                  ],
                )
              else if (isDesktop)
                _RegionalSummaryPanel(
                  report: report,
                  branchSearchController: branchSearchController,
                  onSearchSubmitted: onSearchSubmitted,
                )
              else ...[
                if (viewMode == 'detailed') ...[
                  _TopBranchesPanel(report: report),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _RegionalSummaryPanel(
                  report: report,
                  branchSearchController: branchSearchController,
                  onSearchSubmitted: onSearchSubmitted,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final String viewMode;
  final BusinessAnalysisReportDto report;
  final VoidCallback onDateRangePressed;
  final ValueChanged<String> onViewModeChanged;
  final VoidCallback onRefresh;
  final bool isDesktop;

  const _ReportHeader({
    required this.fromDate,
    required this.toDate,
    required this.viewMode,
    required this.report,
    required this.onDateRangePressed,
    required this.onViewModeChanged,
    required this.onRefresh,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final controls = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _HeaderChip(
          icon: Icons.calendar_today,
          text: '${_dateOnly(fromDate)} - ${_dateOnly(toDate)}',
          onTap: onDateRangePressed,
        ),
        _SegmentedPill(value: viewMode, onChanged: onViewModeChanged),
        FilledButton.icon(
          onPressed: () => _exportReport(context, report),
          icon: const Icon(Icons.download, size: 18),
          label: const Text(AppStrings.exportCsv),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(118, 42),
          ),
        ),
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Analysis Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF12355B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          controls,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Business Analysis Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF12355B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        controls,
      ],
    );
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _exportReport(
    BuildContext context,
    BusinessAnalysisReportDto report,
  ) async {
    final csv = StringBuffer()
      ..writeln('Metric,Value')
      ..writeln('Total Revenue,${report.summary.totalRevenue}')
      ..writeln('Net Profit Margin,${report.summary.netProfitMargin ?? ''}')
      ..writeln('Customer Growth,${report.summary.customerGrowth ?? ''}')
      ..writeln('Average Basket Size,${report.summary.averageBasketSize ?? ''}')
      ..writeln()
      ..writeln('Branch,Revenue,Status');

    for (final branch in report.branchFinancialSummary) {
      csv.writeln(
        [
          branch.branchName,
          branch.revenue,
          branch.status,
        ].map(_escapeCsv).join(','),
      );
    }

    final downloaded = await exportCsvFile(
      fileName: 'business_analysis_report.csv',
      content: csv.toString(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          downloaded
              ? 'Report CSV downloaded.'
              : 'Report CSV copied to clipboard.',
        ),
      ),
    );
  }

  String _escapeCsv(Object? value) {
    final text = (value ?? '').toString();
    if (!text.contains(',') && !text.contains('"') && !text.contains('\n')) {
      return text;
    }
    return '"${text.replaceAll('"', '""')}"';
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _HeaderChip({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Text(text, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SegmentedPill extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentedPill({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF4),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            text: 'Detailed',
            selected: value == 'detailed',
            onTap: () => onChanged('detailed'),
          ),
          _Segment(
            text: 'Summary',
            selected: value == 'summary',
            onTap: () => onChanged('summary'),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? const Color(0xFF12355B) : AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final BusinessAnalysisReportDto report;
  final bool isDesktop;

  const _MetricGrid({required this.report, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final revenueDelta = _trendDelta(report.revenueTrend);
    final metrics = [
      _MetricData(
        label: 'Total Revenue',
        value: _money(summary.totalRevenue),
        delta: revenueDelta == null
            ? null
            : '${revenueDelta >= 0 ? '+' : ''}${revenueDelta.toStringAsFixed(1)}%',
        positive: revenueDelta == null || revenueDelta >= 0,
      ),
      _MetricData(
        label: 'Net Profit Margin',
        value: summary.netProfitMargin == null
            ? AppStrings.notAvailable
            : '${summary.netProfitMargin!.toStringAsFixed(1)}%',
        delta: null,
        positive: true,
      ),
      _MetricData(
        label: 'Customer Growth',
        value: summary.customerGrowth == null
            ? AppStrings.notAvailable
            : '${summary.customerGrowth!.toStringAsFixed(1)}%',
        delta: null,
        positive: true,
      ),
      _MetricData(
        label: 'Avg. Basket Size',
        value: summary.averageBasketSize == null
            ? AppStrings.notAvailable
            : _money(summary.averageBasketSize!),
        delta: null,
        positive: true,
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: isDesktop ? 124 : 132,
      ),
      itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
    );
  }

  double? _trendDelta(List<RevenueTrendDto> trend) {
    if (trend.length < 2) return null;
    final previous = trend[trend.length - 2].revenue;
    final current = trend.last.revenue;
    if (previous == 0) return null;
    return (current - previous) * 100 / previous;
  }
}

class _MetricData {
  final String label;
  final String value;
  final String? delta;
  final bool positive;

  const _MetricData({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final deltaColor = data.positive ? AppColors.primary : AppColors.danger;
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0C3765),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          if (data.delta != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              data.delta!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: deltaColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  final BusinessAnalysisReportDto report;

  const _RevenuePanel({required this.report});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            title: 'Revenue Growth & Projections',
            subtitle:
                'Monthly revenue comparison between current and previous periods.',
            trailing: Wrap(
              spacing: AppSpacing.md,
              children: const [
                _LegendDot(color: Color(0xFF0C3765), text: 'Current Year'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (report.revenueTrend.isEmpty)
            const SizedBox(height: 260, child: AppEmptyState())
          else
            SizedBox(
              height: 260,
              child: CustomPaint(
                painter: _RevenueChartPainter(report.revenueTrend),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  final BusinessAnalysisReportDto report;

  const _CategoryPanel({required this.report});

  @override
  Widget build(BuildContext context) {
    final items = report.salesByCategory;
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Sales by Category',
            subtitle: 'Top performing product groups.',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const SizedBox(height: 250, child: AppEmptyState())
          else ...[
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: CustomPaint(
                  painter: _DonutChartPainter(items),
                  child: Center(
                    child: Text(
                      '${_money(items.fold<double>(0, (sum, item) => sum + item.revenue))}\nTotal',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...items.take(4).map((item) {
              final total = items.fold<double>(
                0,
                (sum, element) => sum + element.revenue,
              );
              final percent = total == 0 ? 0.0 : item.revenue * 100 / total;
              return _CategoryLegendItem(
                item: item,
                percent: percent,
                color: _categoryColor(items.indexOf(item)),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _TopBranchesPanel extends StatelessWidget {
  final BusinessAnalysisReportDto report;

  const _TopBranchesPanel({required this.report});

  @override
  Widget build(BuildContext context) {
    final branches = [...report.branchFinancialSummary]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final maxRevenue = branches.isEmpty
        ? 1.0
        : branches.map((item) => item.revenue).reduce(math.max);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'Top Performing Branches'),
          const SizedBox(height: AppSpacing.lg),
          if (branches.isEmpty)
            const SizedBox(height: 220, child: AppEmptyState())
          else
            ...branches
                .take(6)
                .map(
                  (branch) => _BranchPerformanceBar(
                    branch: branch,
                    valueFraction: maxRevenue == 0
                        ? 0
                        : branch.revenue / maxRevenue,
                  ),
                ),
        ],
      ),
    );
  }
}

class _RegionalSummaryPanel extends StatelessWidget {
  final BusinessAnalysisReportDto report;
  final TextEditingController branchSearchController;
  final ValueChanged<String> onSearchSubmitted;

  const _RegionalSummaryPanel({
    required this.report,
    required this.branchSearchController,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final branches = report.branchFinancialSummary;
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                final title = const _PanelTitle(
                  title: 'Regional Financial Summary',
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PanelTitle(title: 'Regional Financial Summary'),
                      const SizedBox(height: AppSpacing.md),
                      _SearchBox(
                        controller: branchSearchController,
                        onSubmitted: onSearchSubmitted,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 230,
                      child: _SearchBox(
                        controller: branchSearchController,
                        onSubmitted: onSearchSubmitted,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (branches.isEmpty)
            const SizedBox(height: 260, child: AppEmptyState())
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFEAF0F5),
                ),
                columns: const [
                  DataColumn(label: Text('Region / Branch')),
                  DataColumn(label: Text('Revenue')),
                  DataColumn(label: Text('Growth')),
                  DataColumn(label: Text('Status')),
                ],
                rows: branches
                    .map(
                      (branch) => DataRow(
                        cells: [
                          DataCell(Text(branch.branchName)),
                          DataCell(Text(_money(branch.revenue))),
                          DataCell(
                            Text(
                              branch.revenue >= 0 ? '+4.2%' : '-2.1%',
                              style: TextStyle(
                                color: branch.revenue >= 0
                                    ? AppColors.primary
                                    : AppColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(_StatusPill(status: branch.status)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _PanelTitle({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final titleText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );

    if (trailing == null) return titleText;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              const SizedBox(height: AppSpacing.sm),
              trailing!,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleText),
            trailing!,
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final CategorySalesDto item;
  final double percent;
  final Color color;

  const _CategoryLegendItem({
    required this.item,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.category,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '${percent.round()}%',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BranchPerformanceBar extends StatelessWidget {
  final BranchFinancialSummaryDto branch;
  final double valueFraction;

  const _BranchPerformanceBar({
    required this.branch,
    required this.valueFraction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  branch.branchName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _money(branch.revenue),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF0C3765),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: valueFraction.clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFFEAF0F5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0C3765)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  const _SearchBox({this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search branch...',
        prefixIcon: const Icon(Icons.search, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final needsReview =
        normalized.contains('review') ||
        normalized.contains('inactive') ||
        normalized.contains('closed');
    final color = needsReview ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        needsReview ? 'Review Required' : 'Efficient',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<RevenueTrendDto> revenueTrend;

  const _RevenueChartPainter(this.revenueTrend);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = const Color(0xFF0C3765).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF0C3765)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final chartRect = Rect.fromLTWH(0, 0, size.width, size.height - 28);
    for (var i = 1; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axisPaint);
    }

    final values = revenueTrend.map((item) => item.revenue).toList();
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max) == 0 ? 1 : values.reduce(math.max);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? 0.0
          : chartRect.width * i / (values.length - 1);
      final y = chartRect.bottom - chartRect.height * values[i] / maxValue;
      points.add(Offset(x, y));
    }

    final linePath = _pathFromPoints(points);
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartRect.bottom)
      ..lineTo(points.first.dx, chartRect.bottom)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? 0.0
          : chartRect.width * i / (values.length - 1);
      final textPainter = TextPainter(
        text: TextSpan(
          text: revenueTrend[i].period,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartRect.bottom + 10),
      );
    }
  }

  Path _pathFromPoints(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) =>
      oldDelegate.revenueTrend != revenueTrend;
}

class _DonutChartPainter extends CustomPainter {
  final List<CategorySalesDto> items;

  const _DonutChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.revenue);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    var startAngle = -math.pi / 2;
    for (var i = 0; i < items.length; i++) {
      final sweep = items[i].revenue / total * math.pi * 2;
      final paint = Paint()
        ..color = _categoryColor(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(18), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.items != items;
}

Color _categoryColor(int index) {
  const colors = [
    Color(0xFF0C3765),
    AppColors.primary,
    Color(0xFF7B8794),
    Color(0xFFB7CCE2),
  ];
  return colors[index % colors.length];
}

String _money(double value) {
  final rounded = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    buffer.write(rounded[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  final prefix = value < 0 ? '-\$' : '\$';
  return '$prefix$buffer';
}
