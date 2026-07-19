import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_empty_state.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../../shared/shared_components/app_section_card.dart';
import '../control/inventory_replenishment_bloc.dart';
import '../control/inventory_replenishment_event.dart';
import '../control/inventory_replenishment_state.dart';
import '../entity/stock_replenishment_dto.dart';
import 'widgets/replenishment_dispatch_dialog.dart';
import 'widgets/stock_replenishment_request_card.dart';

class InventoryReplenishmentQueuePanel extends StatefulWidget {
  const InventoryReplenishmentQueuePanel({super.key});

  @override
  State<InventoryReplenishmentQueuePanel> createState() =>
      _InventoryReplenishmentQueuePanelState();
}

class _InventoryReplenishmentQueuePanelState
    extends State<InventoryReplenishmentQueuePanel> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryReplenishmentBloc>().add(
      const InventoryReplenishmentFetchRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child:
          BlocConsumer<InventoryReplenishmentBloc, InventoryReplenishmentState>(
            listener: _listen,
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QueueHeader(
                  state: state,
                  onFilterChanged: _fetch,
                  onRefresh: () => _fetch(_statusOf(state)),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildBody(state),
              ],
            ),
          ),
    );
  }

  Widget _buildBody(InventoryReplenishmentState state) {
    return switch (state) {
      InventoryReplenishmentInitial() ||
      InventoryReplenishmentLoading() => const AppLoadingIndicator(),
      InventoryReplenishmentLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => _fetch('ALL'),
      ),
      InventoryReplenishmentLoadSuccess(:final requests) =>
        requests.isEmpty
            ? const AppEmptyState(
                message: StockReplenishmentAppStrings.noRequests,
              )
            : Column(
                children: [
                  for (final request in requests) ...[
                    StockReplenishmentRequestCard(
                      request: request,
                      actions: _RequestActions(
                        request: request,
                        disabled: state.updating,
                        onUpdate: _updateStatus,
                        onReject: _showRejectDialog,
                        onDispatch: _requestDispatchOptions,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
    };
  }

  void _listen(BuildContext context, InventoryReplenishmentState state) {
    if (state is InventoryReplenishmentUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StockReplenishmentAppStrings.statusUpdated),
        ),
      );
    } else if (state is InventoryReplenishmentDispatchOptionsSuccess) {
      _showDispatchDialog(state);
    } else if (state is InventoryReplenishmentDispatchSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StockReplenishmentAppStrings.dispatchCompleted),
        ),
      );
    } else if (state is InventoryReplenishmentUpdateFailure ||
        state is InventoryReplenishmentDispatchFailure) {
      final message = state is InventoryReplenishmentUpdateFailure
          ? state.message
          : (state as InventoryReplenishmentDispatchFailure).message;
      showAppErrorDialog(context, message: message);
    }
  }

  void _requestDispatchOptions(StockReplenishmentRequestDto request) {
    context.read<InventoryReplenishmentBloc>().add(
      InventoryReplenishmentDispatchOptionsRequested(request),
    );
  }

  Future<void> _showDispatchDialog(
    InventoryReplenishmentDispatchOptionsSuccess state,
  ) async {
    final source = await showDialog<StockReplenishmentSourceDto>(
      context: context,
      builder: (_) => ReplenishmentDispatchDialog(sources: state.sources),
    );
    if (!mounted || source == null) {
      return;
    }
    context.read<InventoryReplenishmentBloc>().add(
      InventoryReplenishmentDispatchSubmitted(
        requestId: state.request.requestId,
        request: DispatchStockReplenishmentDto(
          sourceBranchId: source.branchId,
          inventoryNote: null,
        ),
      ),
    );
  }

  void _fetch(String status) {
    context.read<InventoryReplenishmentBloc>().add(
      InventoryReplenishmentFetchRequested(status: status),
    );
  }

  void _updateStatus(
    StockReplenishmentRequestDto request,
    String status,
    String? note,
  ) {
    context.read<InventoryReplenishmentBloc>().add(
      InventoryReplenishmentStatusUpdated(
        requestId: request.requestId,
        request: UpdateStockReplenishmentStatusDto(
          status: status,
          inventoryNote: note,
        ),
      ),
    );
  }

  Future<void> _showRejectDialog(StockReplenishmentRequestDto request) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StockReplenishmentAppStrings.reject),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: StockReplenishmentAppStrings.rejectionReason,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(StockReplenishmentAppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: const Text(StockReplenishmentAppStrings.reject),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null) _updateStatus(request, 'REJECTED', note);
  }

  String _statusOf(InventoryReplenishmentState state) {
    return state is InventoryReplenishmentLoadSuccess ? state.status : 'ALL';
  }
}

class _QueueHeader extends StatelessWidget {
  final InventoryReplenishmentState state;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRefresh;

  const _QueueHeader({
    required this.state,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state is InventoryReplenishmentLoadSuccess
        ? (state as InventoryReplenishmentLoadSuccess).status
        : 'ALL';
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StockReplenishmentAppStrings.inventoryQueue,
              style: AppTextStyles.sectionTitle,
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              StockReplenishmentAppStrings.inventoryQueueSubtitle,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            DropdownButton<String>(
              value: selected,
              items: const [
                DropdownMenuItem(
                  value: 'ALL',
                  child: Text(StockReplenishmentAppStrings.allStatuses),
                ),
                DropdownMenuItem(
                  value: 'PENDING',
                  child: Text(StockReplenishmentAppStrings.pending),
                ),
                DropdownMenuItem(
                  value: 'PROCESSING',
                  child: Text(StockReplenishmentAppStrings.processing),
                ),
                DropdownMenuItem(
                  value: 'FULFILLED',
                  child: Text(StockReplenishmentAppStrings.fulfilled),
                ),
                DropdownMenuItem(
                  value: 'SHIPPED',
                  child: Text(StockReplenishmentAppStrings.shipped),
                ),
                DropdownMenuItem(
                  value: 'REJECTED',
                  child: Text(StockReplenishmentAppStrings.rejected),
                ),
              ],
              onChanged: (value) => onFilterChanged(value ?? 'ALL'),
            ),
            IconButton(
              tooltip: StockReplenishmentAppStrings.refresh,
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequestActions extends StatelessWidget {
  final StockReplenishmentRequestDto request;
  final bool disabled;
  final void Function(
    StockReplenishmentRequestDto request,
    String status,
    String? note,
  )
  onUpdate;
  final ValueChanged<StockReplenishmentRequestDto> onReject;
  final ValueChanged<StockReplenishmentRequestDto> onDispatch;

  const _RequestActions({
    required this.request,
    required this.disabled,
    required this.onUpdate,
    required this.onReject,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    if (request.status == 'PENDING') {
      return Wrap(
        spacing: AppSpacing.xs,
        children: [
          OutlinedButton(
            onPressed: disabled ? null : () => onReject(request),
            child: const Text(StockReplenishmentAppStrings.reject),
          ),
          FilledButton(
            onPressed: disabled
                ? null
                : () => onUpdate(request, 'PROCESSING', null),
            child: const Text(StockReplenishmentAppStrings.startProcessing),
          ),
        ],
      );
    }
    if (request.status == 'PROCESSING') {
      return Wrap(
        spacing: AppSpacing.xs,
        children: [
          OutlinedButton(
            onPressed: disabled ? null : () => onReject(request),
            child: const Text(StockReplenishmentAppStrings.reject),
          ),
          FilledButton(
            onPressed: disabled ? null : () => onDispatch(request),
            child: const Text(StockReplenishmentAppStrings.dispatchMedicines),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
