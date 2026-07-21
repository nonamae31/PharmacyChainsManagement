import 'package:flutter/material.dart';

import '../../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../../../shared/shared_components/app_status_chip.dart';
import '../../entity/stock_replenishment_dto.dart';

class StockReplenishmentRequestCard extends StatelessWidget {
  final StockReplenishmentRequestDto request;
  final Widget? actions;

  const StockReplenishmentRequestCard({
    super.key,
    required this.request,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequestHeader(request: request),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${StockReplenishmentAppStrings.requestedOn}: ${_formatDate(request.requestDate)}',
            style: AppTextStyles.caption,
          ),
          Text(
            '${StockReplenishmentAppStrings.requestedBy}: ${request.requestedByName}',
            style: AppTextStyles.caption,
          ),
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(request.notes!, style: AppTextStyles.body),
          ],
          const Divider(height: AppSpacing.lg),
          for (final item in request.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_outlined,
                    color: AppColors.primary,
                    size: AppSpacing.iconSmall,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(item.medicineName, style: AppTextStyles.body),
                  ),
                  Text(
                    '${item.requestedQuantity} ${item.unit}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (request.inventoryNote != null &&
              request.inventoryNote!.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            Text(request.inventoryNote!, style: AppTextStyles.caption),
          ],
          if (request.sourceBranchName != null) ...[
            const Divider(height: AppSpacing.lg),
            Text(
              '${StockReplenishmentAppStrings.sourceLabel}: '
              '${request.sourceBranchName}',
              style: AppTextStyles.caption,
            ),
          ],
          if (request.dispatchedAt != null)
            Text(
              '${StockReplenishmentAppStrings.dispatchedOn}: '
              '${_formatDateTime(request.dispatchedAt!)}',
              style: AppTextStyles.caption,
            ),
          if (request.receivedAt != null)
            Text(
              '${StockReplenishmentAppStrings.receivedOn}: '
              '${_formatDateTime(request.receivedAt!)}',
              style: AppTextStyles.caption,
            ),
          if (actions != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(alignment: Alignment.centerRight, child: actions!),
          ],
        ],
      ),
    );
  }
}

class _RequestHeader extends StatelessWidget {
  final StockReplenishmentRequestDto request;

  const _RequestHeader({required this.request});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${StockReplenishmentAppStrings.requestNumber} ${request.requestNo}',
          style: AppTextStyles.sectionTitle,
        ),
        AppStatusChip(label: request.status),
        if (request.priority == 'URGENT')
          const AppStatusChip(label: StockReplenishmentAppStrings.urgent),
        if (request.branchName.isNotEmpty)
          Text(request.branchName, style: AppTextStyles.caption),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _formatDateTime(DateTime date) {
  final local = date.toLocal();
  return '${_formatDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
