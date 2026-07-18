import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../entity/medicine_statistics_dto.dart';

class MedicineStatisticsScreen extends StatefulWidget {
  const MedicineStatisticsScreen({super.key});

  @override
  State<MedicineStatisticsScreen> createState() =>
      _MedicineStatisticsScreenState();
}

class _MedicineStatisticsScreenState extends State<MedicineStatisticsScreen> {
  static const _allBranches = 'All Branches';
  static const _allCategories = 'All Categories';
  static const _pageSize = 10;

  final _searchController = TextEditingController();
  String _selectedBranch = _allBranches;
  String _selectedCategory = _allCategories;
  int _forecastWindowDays = 7;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  void _fetchStatistics() {
    context.read<BusinessAdminBloc>().add(
      MedicineStatisticsFetchRequested(
        MedicineStatisticsFilterDto(
          category: _selectedCategory == _allCategories
              ? null
              : _selectedCategory,
          search: _searchController.text.trim(),
          page: 1,
          pageSize: 100,
        ),
      ),
    );
  }

  void _applySearch() {
    setState(() => _page = 1);
    _fetchStatistics();
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
        if (state is MedicineStatisticsLoadSuccess) {
          final branchOptions = _options(
            state.statistics.inventoryItems.map((item) => item.branchName),
            _allBranches,
          );
          final categoryOptions = _options(
            state.statistics.inventoryItems
                .map((item) => item.category)
                .whereType<String>(),
            _allCategories,
          );

          return _StatisticsContent(
            statistics: state.statistics,
            searchController: _searchController,
            selectedBranch: branchOptions.contains(_selectedBranch)
                ? _selectedBranch
                : _allBranches,
            selectedCategory: categoryOptions.contains(_selectedCategory)
                ? _selectedCategory
                : _allCategories,
            branchOptions: branchOptions,
            categoryOptions: categoryOptions,
            forecastWindowDays: _forecastWindowDays,
            page: _page,
            pageSize: _pageSize,
            onSearch: _applySearch,
            onBranchChanged: (value) => setState(() {
              _selectedBranch = value;
              _page = 1;
            }),
            onCategoryChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _page = 1;
              });
              _fetchStatistics();
            },
            onForecastWindowChanged: (days) =>
                setState(() => _forecastWindowDays = days),
            onPageChanged: (page) => setState(() => _page = page),
            onSyncInventory: () {
              _fetchStatistics();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Inventory synced')));
            },
          );
        }
        return AppEmptyState(onRetry: _fetchStatistics);
      },
    );
  }

  List<String> _options(Iterable<String> source, String defaultValue) {
    final values =
        source
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return [defaultValue, ...values];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StatisticsContent extends StatelessWidget {
  final MedicineStatisticsDto statistics;
  final TextEditingController searchController;
  final String selectedBranch;
  final String selectedCategory;
  final List<String> branchOptions;
  final List<String> categoryOptions;
  final int forecastWindowDays;
  final int page;
  final int pageSize;
  final VoidCallback onSearch;
  final ValueChanged<String> onBranchChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<int> onForecastWindowChanged;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onSyncInventory;

  const _StatisticsContent({
    required this.statistics,
    required this.searchController,
    required this.selectedBranch,
    required this.selectedCategory,
    required this.branchOptions,
    required this.categoryOptions,
    required this.forecastWindowDays,
    required this.page,
    required this.pageSize,
    required this.onSearch,
    required this.onBranchChanged,
    required this.onCategoryChanged,
    required this.onForecastWindowChanged,
    required this.onPageChanged,
    required this.onSyncInventory,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredInventoryItems();
    final pageCount = math.max(1, (filteredItems.length / pageSize).ceil());
    final currentPage = page.clamp(1, pageCount);
    final pagedItems = filteredItems
        .skip((currentPage - 1) * pageSize)
        .take(pageSize)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _Toolbar(
              searchController: searchController,
              selectedBranch: selectedBranch,
              selectedCategory: selectedCategory,
              branchOptions: branchOptions,
              categoryOptions: categoryOptions,
              isWide: isWide,
              onSearch: onSearch,
              onBranchChanged: onBranchChanged,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _ForecastPanel(
                      items: filteredItems,
                      forecastWindowDays: forecastWindowDays,
                      onForecastWindowChanged: onForecastWindowChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 3,
                    child: _SummaryColumn(statistics: statistics),
                  ),
                ],
              )
            else ...[
              _ForecastPanel(
                items: filteredItems,
                forecastWindowDays: forecastWindowDays,
                onForecastWindowChanged: onForecastWindowChanged,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SummaryColumn(statistics: statistics),
            ],
            const SizedBox(height: AppSpacing.lg),
            _InventoryPanel(
              items: pagedItems,
              allItems: filteredItems,
              currentPage: currentPage,
              pageCount: pageCount,
              pageSize: pageSize,
              isWide: isWide,
              onPageChanged: onPageChanged,
              onExportCsv: () => _exportCsv(context, filteredItems),
              onSyncInventory: onSyncInventory,
            ),
          ],
        );
      },
    );
  }

  List<MedicineInventoryItemDto> _filteredInventoryItems() {
    if (selectedBranch == _MedicineStatisticsScreenState._allBranches) {
      return statistics.inventoryItems;
    }
    return statistics.inventoryItems
        .where((item) => item.branchName == selectedBranch)
        .toList();
  }

  Future<void> _exportCsv(
    BuildContext context,
    List<MedicineInventoryItemDto> items,
  ) async {
    final buffer = StringBuffer()
      ..writeln(
        'SKU Code,Medicine Name,Category,Total Stock,Reorder Point,Status',
      );
    for (final item in items) {
      final status = _inventoryStatus(item);
      buffer.writeln(
        [
          _skuCode(item),
          item.medicineName,
          item.category ?? AppStrings.notAvailable,
          item.quantityOnHand,
          item.safetyStockLevel,
          status.label,
        ].map(_escapeCsv).join(','),
      );
    }
    final downloaded = await exportCsvFile(
      fileName: 'medicine_inventory.csv',
      content: buffer.toString(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          downloaded
              ? 'Inventory CSV downloaded'
              : 'Inventory CSV copied to clipboard',
        ),
      ),
    );
  }

  String _escapeCsv(Object value) {
    final text = value.toString();
    if (!text.contains(',') && !text.contains('"') && !text.contains('\n')) {
      return text;
    }
    return '"${text.replaceAll('"', '""')}"';
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedBranch;
  final String selectedCategory;
  final List<String> branchOptions;
  final List<String> categoryOptions;
  final bool isWide;
  final VoidCallback onSearch;
  final ValueChanged<String> onBranchChanged;
  final ValueChanged<String> onCategoryChanged;

  const _Toolbar({
    required this.searchController,
    required this.selectedBranch,
    required this.selectedCategory,
    required this.branchOptions,
    required this.categoryOptions,
    required this.isWide,
    required this.onSearch,
    required this.onBranchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: searchController,
      onSubmitted: (_) => onSearch(),
      decoration: const InputDecoration(
        hintText: 'Search medicines, SKUs, or batch numbers...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
    final filters = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: _DropdownFilter(
            value: selectedBranch,
            values: branchOptions,
            label: 'Branch',
            onChanged: onBranchChanged,
          ),
        ),
        SizedBox(
          width: 160,
          child: _DropdownFilter(
            value: selectedCategory,
            values: categoryOptions,
            label: 'Category',
            onChanged: onCategoryChanged,
          ),
        ),
        Tooltip(
          message: 'Apply search',
          child: IconButton.filledTonal(
            onPressed: onSearch,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: AppSpacing.lg),
              const Icon(Icons.notifications_none),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.help_outline),
              const SizedBox(width: AppSpacing.md),
              const CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Admin Portal',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          )
        else
          searchField,
        const SizedBox(height: AppSpacing.lg),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: _TitleBlock()),
              filters,
            ],
          )
        else ...[
          const _TitleBlock(),
          const SizedBox(height: AppSpacing.md),
          filters,
        ],
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicine Statistics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF0B2F5B),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Real-time inventory overview and demand forecasting across branch locations.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> values;
  final String label;
  final ValueChanged<String> onChanged;

  const _DropdownFilter({
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _ForecastPanel extends StatelessWidget {
  final List<MedicineInventoryItemDto> items;
  final int forecastWindowDays;
  final ValueChanged<int> onForecastWindowChanged;

  const _ForecastPanel({
    required this.items,
    required this.forecastWindowDays,
    required this.onForecastWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final trendItems = [...items]
      ..sort((a, b) => b.quantityOnHand.compareTo(a.quantityOnHand));
    final topItems = trendItems.take(3).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEMAND FORECAST',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Top Performance Trends',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 Days')),
                  ButtonSegment(value: 30, label: Text('30 Days')),
                ],
                selected: {forecastWindowDays},
                onSelectionChanged: (value) =>
                    onForecastWindowChanged(value.first),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (topItems.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 620;
                final cards = topItems
                    .map((item) => _TrendCard(item: item))
                    .toList();
                if (isCompact) {
                  return Column(
                    children: cards
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: card,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  children: cards
                      .map(
                        (card) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: card,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final MedicineInventoryItemDto item;

  const _TrendCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final trend = _stockTrendPercent(item);
    final isPositive = trend >= 0;
    final color = isPositive ? AppColors.primary : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.medicineName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF143B66),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'vs safety stock',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 46,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: _sparkValues(item),
                color: color,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final MedicineStatisticsDto statistics;

  const _SummaryColumn({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryCard(
          title: 'Urgent',
          value: statistics.outOfStockCount.toString(),
          label: 'Items Out of Stock',
          icon: Icons.warning_amber,
          background: const Color(0xFF073F6B),
          foreground: Colors.white,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SummaryCard(
          title: 'Supply Chain',
          value: '${(statistics.fulfillmentRate ?? 0).toStringAsFixed(0)}%',
          label: 'Fulfillment Rate',
          icon: Icons.trending_up,
          background: const Color(0xFF86E5E2),
          foreground: const Color(0xFF075E61),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: foreground),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryPanel extends StatelessWidget {
  final List<MedicineInventoryItemDto> items;
  final List<MedicineInventoryItemDto> allItems;
  final int currentPage;
  final int pageCount;
  final int pageSize;
  final bool isWide;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onExportCsv;
  final VoidCallback onSyncInventory;

  const _InventoryPanel({
    required this.items,
    required this.allItems,
    required this.currentPage,
    required this.pageCount,
    required this.pageSize,
    required this.isWide,
    required this.onPageChanged,
    required this.onExportCsv,
    required this.onSyncInventory,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'INVENTORY MASTER LIST',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                TextButton.icon(
                  onPressed: onExportCsv,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export CSV'),
                ),
                TextButton.icon(
                  onPressed: onSyncInventory,
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync Inventory'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            const AppEmptyState()
          else if (isWide)
            _InventoryTable(items: items)
          else
            _InventoryList(items: items),
          const Divider(height: 1),
          _PaginationFooter(
            totalCount: allItems.length,
            currentPage: currentPage,
            pageCount: pageCount,
            pageSize: pageSize,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  final List<MedicineInventoryItemDto> items;

  const _InventoryTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 36,
        headingTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w800,
        ),
        columns: const [
          DataColumn(label: Text('SKU\nCODE')),
          DataColumn(label: Text('MEDICINE NAME')),
          DataColumn(label: Text('CATEGORY')),
          DataColumn(label: Text('TOTAL\nSTOCK')),
          DataColumn(label: Text('REORDER\nPOINT')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('ACTION')),
        ],
        rows: items
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(_skuCode(item))),
                  DataCell(_MedicineNameCell(item: item)),
                  DataCell(Text(item.category ?? AppStrings.notAvailable)),
                  DataCell(Text('${item.quantityOnHand}\nUnits')),
                  DataCell(Text(item.safetyStockLevel.toString())),
                  DataCell(_StatusChip(status: _inventoryStatus(item))),
                  DataCell(_ActionMenu(item: item)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  final List<MedicineInventoryItemDto> items;

  const _InventoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MedicineNameCell(item: item),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${_skuCode(item)} | ${item.category ?? AppStrings.notAvailable}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Stock ${item.quantityOnHand} / Reorder ${item.safetyStockLevel}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusChip(status: _inventoryStatus(item)),
                      _ActionMenu(item: item),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MedicineNameCell extends StatelessWidget {
  final MedicineInventoryItemDto item;

  const _MedicineNameCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.medicineName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          item.batchNumber?.isNotEmpty == true
              ? 'Batch ${item.batchNumber}'
              : item.branchName,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _InventoryStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final MedicineInventoryItemDto item;

  const _ActionMenu({required this.item});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Inventory actions',
      onSelected: (value) async {
        if (value == 'copySku') {
          await Clipboard.setData(ClipboardData(text: _skuCode(item)));
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('SKU copied')));
          return;
        }

        if (value == 'reviewReceipt') {
          final result = await showDialog<_StockReceiptReviewResult>(
            context: context,
            builder: (dialogContext) => _StockReceiptReviewDialog(item: item),
          );
          if (result == null || !context.mounted) return;

          final message = result.decision == _StockReceiptDecision.approved
              ? 'Stock receipt approved for ${item.medicineName}'
              : 'Stock receipt rejected for ${item.medicineName}. '
                    'Reason: ${result.reason}';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'copySku', child: Text('Copy SKU')),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'reviewReceipt',
          child: Text('Check stock receipt'),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

enum _StockReceiptDecision { approved, rejected }

class _StockReceiptReviewResult {
  final _StockReceiptDecision decision;
  final String? reason;

  const _StockReceiptReviewResult({required this.decision, this.reason});
}

class _StockReceiptReviewDialog extends StatefulWidget {
  final MedicineInventoryItemDto item;

  const _StockReceiptReviewDialog({required this.item});

  @override
  State<_StockReceiptReviewDialog> createState() =>
      _StockReceiptReviewDialogState();
}

class _StockReceiptReviewDialogState extends State<_StockReceiptReviewDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _reasonError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _approveReceipt() {
    Navigator.of(context).pop(
      const _StockReceiptReviewResult(decision: _StockReceiptDecision.approved),
    );
  }

  void _rejectReceipt() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() {
        _reasonError = 'Rejection reason is required';
      });
      return;
    }

    Navigator.of(context).pop(
      _StockReceiptReviewResult(
        decision: _StockReceiptDecision.rejected,
        reason: reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AlertDialog(
      title: const Text('Check stock receipt'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.medicineName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${_skuCode(item)} • ${item.category}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: const [
                  _ReceiptEvidencePreview(
                    title: 'Medicine front photo',
                    subtitle: 'Box front side',
                    icon: Icons.medication_outlined,
                  ),
                  _ReceiptEvidencePreview(
                    title: 'Medicine back photo',
                    subtitle: 'Box back side',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _ReceiptEvidencePreview(
                    title: 'Medicine label photo',
                    subtitle: 'Name and expiry label',
                    icon: Icons.label_outline,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Rejection reason',
                  hintText: 'Enter reason if rejecting this medicine stock',
                  errorText: _reasonError,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (_reasonError == null) return;
                  setState(() {
                    _reasonError = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          onPressed: _rejectReceipt,
          icon: const Icon(Icons.close),
          label: const Text('Reject'),
        ),
        FilledButton.icon(
          onPressed: _approveReceipt,
          icon: const Icon(Icons.check),
          label: const Text('Approve'),
        ),
      ],
    );
  }
}

class _ReceiptEvidencePreview extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ReceiptEvidencePreview({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => _ReceiptEvidenceViewer(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
      ),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 42, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptEvidenceViewer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ReceiptEvidenceViewer({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 96, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int totalCount;
  final int currentPage;
  final int pageCount;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const _PaginationFooter({
    required this.totalCount,
    required this.currentPage,
    required this.pageCount,
    required this.pageSize,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = totalCount == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;
    final end = math.min(currentPage * pageSize, totalCount);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Showing $start-$end of $totalCount medicines',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(width: AppSpacing.xl),
          IconButton.outlined(
            tooltip: 'Previous page',
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(math.min(pageCount, 3), (index) {
            final pageNumber = index + 1;
            final selected = pageNumber == currentPage;
            return SizedBox.square(
              dimension: 36,
              child: selected
                  ? FilledButton(
                      onPressed: () => onPageChanged(pageNumber),
                      child: Text(pageNumber.toString()),
                    )
                  : OutlinedButton(
                      onPressed: () => onPageChanged(pageNumber),
                      child: Text(pageNumber.toString()),
                    ),
            );
          }),
          IconButton.outlined(
            tooltip: 'Next page',
            onPressed: currentPage < pageCount
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(1, maxValue - minValue);
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y =
          size.height - ((values[index] - minValue) / range * size.height);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _InventoryStatus {
  final String label;
  final Color foreground;
  final Color background;

  const _InventoryStatus({
    required this.label,
    required this.foreground,
    required this.background,
  });
}

_InventoryStatus _inventoryStatus(MedicineInventoryItemDto item) {
  if (item.quantityOnHand <= 0) {
    return const _InventoryStatus(
      label: 'Out of Stock',
      foreground: AppColors.danger,
      background: Color(0xFFFFE4E6),
    );
  }
  if (item.quantityOnHand <= item.safetyStockLevel) {
    return const _InventoryStatus(
      label: 'Low Stock',
      foreground: AppColors.warning,
      background: Color(0xFFFFF3CD),
    );
  }
  return const _InventoryStatus(
    label: 'In Stock',
    foreground: AppColors.success,
    background: Color(0xFFDCFCE7),
  );
}

String _skuCode(MedicineInventoryItemDto item) {
  final compact = item.medicineId.replaceAll('-', '').toUpperCase();
  final suffix = compact.substring(0, math.min(5, compact.length));
  return 'MRX-$suffix';
}

double _stockTrendPercent(MedicineInventoryItemDto item) {
  final baseline = math.max(1, item.safetyStockLevel);
  return ((item.quantityOnHand - baseline) / baseline) * 100;
}

List<double> _sparkValues(MedicineInventoryItemDto item) {
  final stock = item.quantityOnHand.toDouble();
  final reorder = math.max(1, item.safetyStockLevel).toDouble();
  final midpoint = (stock + reorder) / 2;
  return [reorder, midpoint, stock * 0.85, stock, midpoint + stock * 0.12];
}
