import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../control/branch_revenue_state.dart';
import '../../entity/branch_revenue_dto.dart';
import 'payment_method_revenue_panel.dart';
import 'revenue_period_selector.dart';

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
          RevenuePeriodSelector(
            period: state.period,
            fromDate: revenue.fromDate,
            toDate: revenue.toDate,
            onPeriodSelected: onPeriodSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          _RevenueMetricsGrid(revenue: revenue),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth < AppSpacing.stackedPanelBreakpoint
                ? Column(
                    children: [
                      PaymentMethodRevenuePanel(
                        paymentMethods: revenue.paymentMethods,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _CategoryPanel(state: state),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PaymentMethodRevenuePanel(
                          paymentMethods: revenue.paymentMethods,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _CategoryPanel(state: state)),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PerformancePanel(state: state),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) =>
    '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';

class _RevenueMetricsGrid extends StatelessWidget {
  final BranchRevenueDto revenue;

  const _RevenueMetricsGrid({required this.revenue});

  @override
  Widget build(BuildContext context) {
    final totalRevenue = AppMetricCard(
      label: AppStrings.totalRevenue,
      value: _formatCurrency(revenue.totalRevenue),
      icon: Icons.account_balance_wallet_outlined,
    );
    final totalInvoices = AppMetricCard(
      label: AppStrings.totalInvoices,
      value: revenue.totalInvoices.toString(),
      icon: Icons.receipt_long_outlined,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
          return Column(
            children: [
              totalRevenue,
              const SizedBox(height: AppSpacing.sm),
              totalInvoices,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: totalRevenue),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: totalInvoices),
          ],
        );
      },
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
