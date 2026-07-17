import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_chart.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_responsive_metric_grid.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../control/branch_revenue_state.dart';
import '../../entity/branch_revenue_dto.dart';

class BranchRevenueContent extends StatelessWidget {
  final BranchRevenueLoadSuccess state;
  final ValueChanged<String> onPeriodSelected;

  const BranchRevenueContent({
    super.key,
    required this.state,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final revenue = state.revenue;
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text(AppStrings.daily)),
                ButtonSegment(value: 'weekly', label: Text(AppStrings.weekly)),
                ButtonSegment(
                  value: 'monthly',
                  label: Text(AppStrings.monthly),
                ),
                ButtonSegment(value: 'custom', label: Text(AppStrings.custom)),
              ],
              selected: {state.period},
              onSelectionChanged: (selection) =>
                  onPeriodSelected(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _RevenueMetricsGrid(revenue: revenue),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth < AppSpacing.stackedPanelBreakpoint
                ? Column(
                    children: [
                      _TrendPanel(state: state),
                      const SizedBox(height: AppSpacing.md),
                      _CategoryPanel(state: state),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _TrendPanel(state: state)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _CategoryPanel(state: state)),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PerformancePanel(state: state),
          const SizedBox(height: AppSpacing.md),
          const _InsightCardsRow(),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) =>
    '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';
String _formatPercent(double value) =>
    '${value.toStringAsFixed(1)}${AppStrings.percentSymbol}';

class _RevenueMetricsGrid extends StatelessWidget {
  final BranchRevenueDto revenue;

  const _RevenueMetricsGrid({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return AppResponsiveMetricGrid(
      children: [
        AppMetricCard(
          label: AppStrings.totalRevenue,
          value: _formatCurrency(revenue.totalRevenue),
          icon: Icons.account_balance_wallet_outlined,
        ),
        AppMetricCard(
          label: AppStrings.averageTicket,
          value: _formatCurrency(revenue.averageTicket),
          icon: Icons.shopping_cart_outlined,
        ),
        AppMetricCard(
          label: AppStrings.transactions,
          value: revenue.transactions.toString(),
          icon: Icons.group_add_outlined,
        ),
        AppMetricCard(
          label: AppStrings.grossMargin,
          value: revenue.grossMarginPercent == null
              ? AppStrings.unavailable
              : _formatPercent(revenue.grossMarginPercent!),
          icon: Icons.calculate_outlined,
        ),
      ],
    );
  }
}

class _InsightCardsRow extends StatelessWidget {
  const _InsightCardsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
          ? const Column(
              children: [
                _InsightCard(
                  title: AppStrings.revenueForecast,
                  message: AppStrings.forecastMessage,
                  emphasized: true,
                ),
                SizedBox(height: AppSpacing.sm),
                _InsightCard(
                  title: AppStrings.optimizationInsights,
                  message: AppStrings.insightsMessage,
                ),
              ],
            )
          : const Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    title: AppStrings.revenueForecast,
                    message: AppStrings.forecastMessage,
                    emphasized: true,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InsightCard(
                    title: AppStrings.optimizationInsights,
                    message: AppStrings.insightsMessage,
                  ),
                ),
              ],
            ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  final BranchRevenueLoadSuccess state;

  const _TrendPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.revenueTrend,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            AppStrings.revenueTrendSubtitle,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          AppBarChart(
            values: state.revenue.revenueTrend
                .map((item) => item.revenue)
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  final BranchRevenueLoadSuccess state;

  const _CategoryPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final categories = state.revenue.categoryRevenue;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.byCategory, style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          if (categories.isEmpty)
            const AppEmptyState()
          else
            for (final item in categories.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.category, style: AppTextStyles.body),
                        ),
                        Text(
                          '${AppStrings.currencySymbol}${item.revenue.toStringAsFixed(0)} (${item.contributionPercent.toStringAsFixed(0)}${AppStrings.percentSymbol})',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    LinearProgressIndicator(
                      value: (item.contributionPercent / 100)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      color: AppColors.primary,
                      backgroundColor: AppColors.border,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  final BranchRevenueLoadSuccess state;

  const _PerformancePanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.recentPerformance,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.visiblePerformance.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
                  return Column(
                    children: [
                      for (final item in state.visiblePerformance) ...[
                        AppMobileDetailCard(
                          title: item.timeBlock,
                          trailing: AppStatusChip(label: item.status),
                          details: [
                            AppMobileDetailItem(
                              label: AppStrings.transactions,
                              value: item.transactions.toString(),
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.revenue,
                              value:
                                  '${AppStrings.currencySymbol}${item.revenue.toStringAsFixed(2)}',
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.averageOrder,
                              value:
                                  '${AppStrings.currencySymbol}${item.averageOrder.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text(AppStrings.timeBlock)),
                      DataColumn(label: Text(AppStrings.transactions)),
                      DataColumn(label: Text(AppStrings.revenue)),
                      DataColumn(label: Text(AppStrings.averageOrder)),
                      DataColumn(label: Text(AppStrings.status)),
                    ],
                    rows: state.visiblePerformance
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.timeBlock)),
                              DataCell(Text(item.transactions.toString())),
                              DataCell(
                                Text(
                                  '${AppStrings.currencySymbol}${item.revenue.toStringAsFixed(2)}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${AppStrings.currencySymbol}${item.averageOrder.toStringAsFixed(2)}',
                                ),
                              ),
                              DataCell(AppStatusChip(label: item.status)),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final bool emphasized;

  const _InsightCard({
    required this.title,
    required this.message,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      color: emphasized ? AppColors.primary : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: emphasized ? AppColors.surface : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: emphasized ? AppColors.tealSoft : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
