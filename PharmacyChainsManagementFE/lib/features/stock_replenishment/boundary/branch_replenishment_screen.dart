import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../core/theme/branch_manager_app_theme.dart';
import '../../../shared/shared_components/app_empty_state.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_error_view.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/branch_replenishment_bloc.dart';
import '../control/branch_replenishment_event.dart';
import '../control/branch_replenishment_state.dart';
import 'widgets/branch_replenishment_form_dialog.dart';
import 'widgets/stock_replenishment_request_card.dart';

class BranchReplenishmentScreen extends StatefulWidget {
  const BranchReplenishmentScreen({super.key});

  @override
  State<BranchReplenishmentScreen> createState() =>
      _BranchReplenishmentScreenState();
}

class _BranchReplenishmentScreenState extends State<BranchReplenishmentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchReplenishmentBloc>().add(
      const BranchReplenishmentFetchRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BranchReplenishmentBloc, BranchReplenishmentState>(
      listener: _listen,
      builder: (context, state) => Column(
        children: [
          _Header(
            onClose: () => Navigator.of(context).pop(),
            onCreate: state is BranchReplenishmentLoadSuccess
                ? () => _openCreateDialog(state)
                : null,
          ),
          const Divider(height: AppSpacing.hairline),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(BranchReplenishmentState state) {
    return switch (state) {
      BranchReplenishmentInitial() ||
      BranchReplenishmentLoading() => const AppLoadingIndicator(),
      BranchReplenishmentLoadFailure(:final message) => AppErrorView(
        message: message,
        onRetry: () => context.read<BranchReplenishmentBloc>().add(
          const BranchReplenishmentFetchRequested(),
        ),
      ),
      BranchReplenishmentLoadSuccess(:final requests) =>
        requests.isEmpty
            ? const AppEmptyState(
                message: StockReplenishmentAppStrings.noRequests,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: requests.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    StockReplenishmentRequestCard(request: requests[index]),
              ),
    };
  }

  void _listen(BuildContext context, BranchReplenishmentState state) {
    if (state is BranchReplenishmentSubmitSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StockReplenishmentAppStrings.requestCreated),
        ),
      );
    } else if (state is BranchReplenishmentSubmitFailure) {
      showAppErrorDialog(context, message: state.message);
    }
  }

  void _openCreateDialog(BranchReplenishmentLoadSuccess state) {
    showDialog<void>(
      context: context,
      barrierDismissible: !state.submitting,
      builder: (_) => BranchReplenishmentFormDialog(
        options: state.options,
        submitting: state.submitting,
        onSubmit: (request) => context.read<BranchReplenishmentBloc>().add(
          BranchReplenishmentSubmitted(request),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onCreate;

  const _Header({required this.onClose, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StockReplenishmentAppStrings.requestMedicine,
                  style: AppTextStyles.pageTitle,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  StockReplenishmentAppStrings.requestMedicineSubtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text(StockReplenishmentAppStrings.createRequest),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: StockReplenishmentAppStrings.close,
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
