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
import '../../control/branch_dashboard_state.dart';
import '../../entity/branch_dashboard_dto.dart';

class BranchDashboardContent extends StatelessWidget {
  final BranchDashboardLoadSuccess state;
  final VoidCallback onUpdateRoster;
  final VoidCallback onFilterAlerts;
  final ValueChanged<String> onPeriodSelected;

  const BranchDashboardContent({
    super.key,
    required this.state,
    required this.onUpdateRoster,
    required this.onFilterAlerts,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = state.dashboard.metrics;
    return SingleChildScrollView(
      child: Column(
        children: [
          AppResponsiveMetricGrid(
            children: [
              AppMetricCard(
                label: AppStrings.todayRevenue,
                value: _currency(metrics.todayRevenue),
                icon: Icons.payments_outlined,
                helper: _percent(metrics.revenueChangePercent),
              ),
              AppMetricCard(
                label: AppStrings.activeStaff,
                value: '${metrics.activeStaff} / ${metrics.totalStaff}',
                icon: Icons.groups_outlined,
                helper: metrics.totalStaff > 0 &&
                        metrics.activeStaff >= metrics.totalStaff
                    ? AppStrings.fullStaff
                    : '${metrics.totalStaff - metrics.activeStaff} ${AppStrings.staffOnBreak}',
                accentColor:
                    metrics.totalStaff > 0 &&
                        metrics.activeStaff < metrics.totalStaff
                    ? AppColors.warning
                    : AppColors.teal,
              ),
              AppMetricCard(
                label: AppStrings.stockAlerts,
                value: '${metrics.stockAlerts} ${AppStrings.items}',
                icon: Icons.warning_amber_outlined,
                helper: AppStrings.requiresRestock,
                accentColor: AppColors.danger,
              ),
              AppMetricCard(
                label: AppStrings.branchEfficiency,
                value: _percent(metrics.branchEfficiencyPercent),
                icon: Icons.analytics_outlined,
                helper: metrics.branchEfficiencyPercent >= 70
                    ? AppStrings.healthy
                    : AppStrings.needsAttention,
                emphasized: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth < AppSpacing.stackedPanelBreakpoint
                ? Column(
                    children: [
                      _RevenuePanel(
                        state: state,
                        onPeriodSelected: onPeriodSelected,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _StaffPanel(state: state, onUpdateRoster: onUpdateRoster),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _RevenuePanel(
                          state: state,
                          onPeriodSelected: onPeriodSelected,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StaffPanel(
                          state: state,
                          onUpdateRoster: onUpdateRoster,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InventoryPanel(state: state, onFilterAlerts: onFilterAlerts),
        ],
      ),
    );
  }

  String _currency(double value) =>
      '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';
  String _percent(double value) =>
      '${value.toStringAsFixed(1)}${AppStrings.percentSymbol}';
}

class _RevenuePanel extends StatelessWidget {
  final BranchDashboardLoadSuccess state;
  final ValueChanged<String> onPeriodSelected;

  const _RevenuePanel({required this.state, required this.onPeriodSelected});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final selector = SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'month', label: Text(AppStrings.month)),
                  ButtonSegment(
                    value: 'quarter',
                    label: Text(AppStrings.quarter),
                  ),
                  ButtonSegment(value: 'year', label: Text(AppStrings.year)),
                ],
                selected: {state.trendPeriod},
                onSelectionChanged: (selection) =>
                    onPeriodSelected(selection.first),
              );
              if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.revenueStatistics,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: selector,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  const Expanded(
                    child: Text(
                      AppStrings.revenueStatistics,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  selector,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            AppStrings.revenueStatisticsSubtitle,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          AppLineChart(
            values: state.dashboard.revenueTrend
                .map((item) => item.revenue)
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _StaffPanel extends StatelessWidget {
  final BranchDashboardLoadSuccess state;
  final VoidCallback onUpdateRoster;

  const _StaffPanel({required this.state, required this.onUpdateRoster});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.monitorStaff,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              Text(AppStrings.viewAll, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.visibleStaff.isEmpty)
            const AppEmptyState()
          else
            for (final staff in state.visibleStaff)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        staff.fullName.isEmpty ? '' : staff.fullName[0],
                        style: const TextStyle(color: AppColors.surface),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.fullName,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(staff.roleName, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text(
                      '${AppStrings.currencySymbol}${staff.salesRevenue.toStringAsFixed(0)}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onUpdateRoster,
              child: const Text(AppStrings.updateShiftRoster),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryPanel extends StatelessWidget {
  final BranchDashboardLoadSuccess state;
  final VoidCallback onFilterAlerts;

  const _InventoryPanel({required this.state, required this.onFilterAlerts});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InventoryPanelHeader(onFilterAlerts: onFilterAlerts),
          const SizedBox(height: AppSpacing.sm),
          if (state.visibleInventory.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
                  ? _InventoryAlertsList(items: state.visibleInventory)
                  : _InventoryAlertsTable(items: state.visibleInventory),
            ),
        ],
      ),
    );
  }
}

class _InventoryPanelHeader extends StatelessWidget {
  final VoidCallback onFilterAlerts;

  const _InventoryPanelHeader({required this.onFilterAlerts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.inventoryStatus, style: AppTextStyles.sectionTitle),
            SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.inventoryStatusSubtitle,
              style: AppTextStyles.caption,
            ),
          ],
        );
        final action = OutlinedButton.icon(
          onPressed: onFilterAlerts,
          icon: const Icon(Icons.filter_list),
          label: const Text(AppStrings.filterAlerts),
        );
        if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: AppSpacing.sm),
              SizedBox(width: double.infinity, child: action),
            ],
          );
        }
        return Row(children: [const Expanded(child: heading), action]);
      },
    );
  }
}

class _InventoryAlertsList extends StatelessWidget {
  final List<DashboardInventoryDto> items;

  const _InventoryAlertsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          AppMobileDetailCard(
            title: item.medicineName,
            subtitle: item.sku,
            leading: const Icon(
              Icons.medication_outlined,
              color: AppColors.primary,
            ),
            trailing: AppStatusChip(label: item.status),
            details: [
              AppMobileDetailItem(
                label: AppStrings.category,
                value: item.category,
              ),
              AppMobileDetailItem(
                label: AppStrings.currentStock,
                value: item.currentStock.toString(),
              ),
              AppMobileDetailItem(
                label: AppStrings.reorderPoint,
                value: item.reorderPoint.toString(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _InventoryAlertsTable extends StatelessWidget {
  final List<DashboardInventoryDto> items;

  const _InventoryAlertsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text(AppStrings.skuItemName)),
          DataColumn(label: Text(AppStrings.category)),
          DataColumn(label: Text(AppStrings.currentStock)),
          DataColumn(label: Text(AppStrings.reorderPoint)),
          DataColumn(label: Text(AppStrings.status)),
        ],
        rows: items
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.sku, style: AppTextStyles.caption),
                        Text(
                          item.medicineName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(item.category)),
                  DataCell(Text(item.currentStock.toString())),
                  DataCell(Text(item.reorderPoint.toString())),
                  DataCell(AppStatusChip(label: item.status)),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
