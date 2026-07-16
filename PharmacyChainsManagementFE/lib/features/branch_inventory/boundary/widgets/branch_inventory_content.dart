import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_responsive_metric_grid.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../control/branch_inventory_state.dart';

typedef InventoryFilterChanged = void Function(String category, String status);

class BranchInventoryContent extends StatelessWidget {
  final BranchInventoryLoadSuccess state;
  final InventoryFilterChanged onFilterChanged;
  final ValueChanged<int> onPageChanged;

  const BranchInventoryContent({
    super.key,
    required this.state,
    required this.onFilterChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inventory = state.inventory;
    return SingleChildScrollView(
      child: Column(
        children: [
          AppResponsiveMetricGrid(
            children: [
              AppMetricCard(
                label: AppStrings.totalItems,
                value: inventory.totalItems.toString(),
                icon: Icons.inventory_2_outlined,
              ),
              AppMetricCard(
                label: AppStrings.criticalStock,
                value: inventory.criticalStock.toString(),
                icon: Icons.warning_amber_outlined,
                accentColor: AppColors.danger,
              ),
              AppMetricCard(
                label: AppStrings.inTransit,
                value: inventory.inTransit.toString(),
                icon: Icons.local_shipping_outlined,
              ),
              AppMetricCard(
                label: AppStrings.inventoryValue,
                value:
                    '${AppStrings.currencySymbol}${inventory.inventoryValue.toStringAsFixed(1)}',
                icon: Icons.account_balance_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            child: Column(
              children: [
                _InventoryFilters(
                  state: state,
                  onFilterChanged: onFilterChanged,
                ),
                const SizedBox(height: AppSpacing.md),
                if (inventory.items.isEmpty)
                  const AppEmptyState()
                else
                  _InventoryTable(state: state),
                const SizedBox(height: AppSpacing.sm),
                _Pagination(state: state, onPageChanged: onPageChanged),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _InventoryBanner(),
        ],
      ),
    );
  }
}

class _InventoryFilters extends StatelessWidget {
  final BranchInventoryLoadSuccess state;
  final InventoryFilterChanged onFilterChanged;

  const _InventoryFilters({required this.state, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    final categories = ['all', ...state.inventory.categories];
    const statuses = [
      'all',
      AppStrings.inStock,
      AppStrings.lowStock,
      AppStrings.critical,
      AppStrings.outOfStock,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final categoryFilter = SizedBox(
          width: constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
              ? double.infinity
              : AppSpacing.categoryFilterWidth,
          child: DropdownButtonFormField<String>(
            initialValue: categories.contains(state.category)
                ? state.category
                : 'all',
            items: categories
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == 'all' ? AppStrings.allCategories : value,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) => onFilterChanged(value ?? 'all', state.status),
          ),
        );
        final statusFilter = SizedBox(
          width: constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
              ? double.infinity
              : AppSpacing.statusFilterWidth,
          child: DropdownButtonFormField<String>(
            initialValue: statuses.contains(state.status)
                ? state.status
                : 'all',
            items: statuses
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == 'all' ? AppStrings.allStatuses : value,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) =>
                onFilterChanged(state.category, value ?? 'all'),
          ),
        );
        final summary = Text(
          '${AppStrings.showing} ${state.inventory.items.length} ${AppStrings.ofLabel} ${state.inventory.totalRecords} ${AppStrings.results}',
          style: AppTextStyles.caption,
        );
        if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              categoryFilter,
              const SizedBox(height: AppSpacing.sm),
              statusFilter,
              const SizedBox(height: AppSpacing.sm),
              summary,
            ],
          );
        }
        return Row(
          children: [
            categoryFilter,
            const SizedBox(width: AppSpacing.sm),
            statusFilter,
            const Spacer(),
            summary,
          ],
        );
      },
    );
  }
}

class _InventoryTable extends StatelessWidget {
  final BranchInventoryLoadSuccess state;

  const _InventoryTable({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
          return Column(
            children: [
              for (final item in state.inventory.items) ...[
                AppMobileDetailCard(
                  title: item.medicineName,
                  subtitle:
                      '${item.sku} ${AppStrings.itemSeparator} ${item.category}',
                  leading: const Icon(
                    Icons.medication_outlined,
                    color: AppColors.primary,
                  ),
                  trailing: AppStatusChip(label: item.status),
                  details: [
                    AppMobileDetailItem(
                      label: AppStrings.currentStock,
                      value: item.currentStock.toString(),
                    ),
                    AppMobileDetailItem(
                      label: AppStrings.reorderPoint,
                      value: item.reorderPoint.toString(),
                    ),
                    AppMobileDetailItem(
                      label: AppStrings.supplier,
                      value: item.supplier,
                    ),
                    AppMobileDetailItem(
                      label: AppStrings.lastSync,
                      value: _relativeTime(item.lastSync),
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
              DataColumn(label: Text(AppStrings.itemDetails)),
              DataColumn(label: Text(AppStrings.currentStock)),
              DataColumn(label: Text(AppStrings.reorderPoint)),
              DataColumn(label: Text(AppStrings.status)),
              DataColumn(label: Text(AppStrings.supplier)),
              DataColumn(label: Text(AppStrings.lastSync)),
            ],
            rows: state.inventory.items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            const Icon(
                              Icons.medication_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.medicineName,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${item.sku} • ${item.category}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          item.currentStock.toString(),
                          style: AppTextStyles.body.copyWith(
                            color: item.currentStock <= item.reorderPoint
                                ? AppColors.danger
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(Text(item.reorderPoint.toString())),
                      DataCell(AppStatusChip(label: item.status)),
                      DataCell(Text(item.supplier)),
                      DataCell(Text(_relativeTime(item.lastSync))),
                    ],
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppStrings.minuteShort}';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} ${AppStrings.hourShort}';
    }
    return '${difference.inDays} ${AppStrings.dayShort}';
  }
}

class _Pagination extends StatelessWidget {
  final BranchInventoryLoadSuccess state;
  final ValueChanged<int> onPageChanged;

  const _Pagination({required this.state, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final pages = (state.inventory.totalRecords / state.inventory.pageSize)
        .ceil()
        .clamp(1, 999999);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: state.inventory.page > 1
              ? () => onPageChanged(state.inventory.page - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${state.inventory.page} / $pages', style: AppTextStyles.body),
        IconButton(
          onPressed: state.inventory.page < pages
              ? () => onPageChanged(state.inventory.page + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _InventoryBanner extends StatelessWidget {
  const _InventoryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.teal],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const icon = Icon(
            Icons.hub_outlined,
            color: AppColors.surface,
            size: AppSpacing.xxl,
          );
          const copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.centralHub, style: AppTextStyles.bannerTitle),
              SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.centralHubMessage,
                style: AppTextStyles.bannerBody,
              ),
            ],
          );
          if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                SizedBox(height: AppSpacing.md),
                copy,
              ],
            );
          }
          return const Row(
            children: [
              icon,
              SizedBox(width: AppSpacing.lg),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }
}
