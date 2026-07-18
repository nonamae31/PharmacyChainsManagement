import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/csv_download_service.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_page_header.dart';
import '../control/branch_inventory_bloc.dart';
import '../control/branch_inventory_event.dart';
import '../control/branch_inventory_state.dart';
import 'widgets/branch_inventory_content.dart';

class BranchInventoryScreen extends StatefulWidget {
  const BranchInventoryScreen({super.key});

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
                  searchHint: AppStrings.searchInventory,
                  onSearchChanged: (value) => _search(state, value),
                  actions: [
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
}
