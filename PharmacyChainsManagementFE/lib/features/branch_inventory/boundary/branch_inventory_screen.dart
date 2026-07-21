import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../core/network/csv_download_service.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../control/branch_inventory_bloc.dart';
import '../control/branch_inventory_event.dart';
import '../control/branch_inventory_state.dart';
import '../../stock_replenishment/boundary/branch_replenishment_screen.dart';
import '../../stock_replenishment/control/branch_replenishment_bloc.dart';
import 'widgets/branch_inventory_content.dart';

class BranchInventoryScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const BranchInventoryScreen({super.key, this.onProfileTap});

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchInventoryBloc>().add(
      const BranchInventoryFetchRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BranchInventoryBloc, BranchInventoryState>(
      listener: (context, state) {
        if (state is BranchInventoryExportSuccess) {
          downloadCsv(state.bytes, AppStrings.inventoryCsvFile);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStrings.exportReady)));
        }
      },
      builder: (context, state) {
        final mobile =
            MediaQuery.sizeOf(context).width <
            AppSpacing.mobileHeaderBreakpoint;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(mobile ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              children: [
                AppPageHeader(
                  title: AppStrings.inventoryTitle,
                  subtitle: AppStrings.inventorySubtitle,
                  onProfileTap: widget.onProfileTap,
                  searchHint: AppStrings.searchInventory,
                  onSearchChanged: (value) => _search(state, value),
                  actions: [
                    FilledButton.icon(
                      onPressed: state is BranchInventoryLoadSuccess
                          ? _openReplenishmentRequests
                          : null,
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: const Text(
                        StockReplenishmentAppStrings.requestMedicine,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: state is BranchInventoryLoadSuccess
                          ? () => context.read<BranchInventoryBloc>().add(
                              const BranchInventoryExportRequested(),
                            )
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text(AppStrings.exportCsv),
                    ),
                  ],
                ),
                SizedBox(height: mobile ? AppSpacing.md : AppSpacing.lg),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BranchInventoryState state) {
    return switch (state) {
      BranchInventoryInitial() ||
      BranchInventoryLoading() => const AppLoadingIndicator(),
      BranchInventoryLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => context.read<BranchInventoryBloc>().add(
          const BranchInventoryFetchRequested(),
        ),
      ),
      BranchInventoryLoadSuccess() => BranchInventoryContent(
        state: state,
        onFilterChanged: _filter,
        onPageChanged: _page,
      ),
    };
  }

  void _search(BranchInventoryState state, String value) {
    if (state is! BranchInventoryLoadSuccess) return;
    context.read<BranchInventoryBloc>().add(
      BranchInventoryFetchRequested(
        search: value,
        category: state.category,
        status: state.status,
      ),
    );
  }

  void _filter(String category, String status) {
    final state = context.read<BranchInventoryBloc>().state;
    if (state is! BranchInventoryLoadSuccess) return;
    context.read<BranchInventoryBloc>().add(
      BranchInventoryFetchRequested(
        search: state.search,
        category: category,
        status: status,
      ),
    );
  }

  void _page(int page) {
    final state = context.read<BranchInventoryBloc>().state;
    if (state is! BranchInventoryLoadSuccess) return;
    context.read<BranchInventoryBloc>().add(
      BranchInventoryFetchRequested(
        search: state.search,
        category: state.category,
        status: state.status,
        page: page,
      ),
    );
  }

  void _openReplenishmentRequests() {
    final bloc = context.read<BranchReplenishmentBloc>();
    final size = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: Dialog(
          child: SizedBox(
            width: math.min(
              size.width - AppSpacing.lg,
              AppSpacing.replenishmentDialogWidth,
            ),
            height: math.min(
              size.height - AppSpacing.lg,
              AppSpacing.replenishmentDialogHeight,
            ),
            child: const BranchReplenishmentScreen(),
          ),
        ),
      ),
    );
  }
}
