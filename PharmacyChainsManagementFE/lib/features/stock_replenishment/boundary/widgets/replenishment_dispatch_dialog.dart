import 'package:flutter/material.dart';

import '../../../../core/constants/stock_replenishment_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../entity/stock_replenishment_dto.dart';

class ReplenishmentDispatchDialog extends StatefulWidget {
  final List<StockReplenishmentSourceDto> sources;

  const ReplenishmentDispatchDialog({super.key, required this.sources});

  @override
  State<ReplenishmentDispatchDialog> createState() =>
      _ReplenishmentDispatchDialogState();
}

class _ReplenishmentDispatchDialogState
    extends State<ReplenishmentDispatchDialog> {
  late StockReplenishmentSourceDto _selectedSource;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.sources.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(StockReplenishmentAppStrings.dispatchMedicines),
      content: SizedBox(
        width: AppSpacing.dialogWidthStandard,
        child: DropdownButtonFormField<StockReplenishmentSourceDto>(
          initialValue: _selectedSource,
          decoration: const InputDecoration(
            labelText: StockReplenishmentAppStrings.selectSource,
          ),
          items: widget.sources
              .map(
                (source) => DropdownMenuItem(
                  value: source,
                  child: Text(source.branchName),
                ),
              )
              .toList(growable: false),
          onChanged: (source) {
            if (source != null) {
              setState(() => _selectedSource = source);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(StockReplenishmentAppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedSource),
          child: const Text(StockReplenishmentAppStrings.dispatchMedicines),
        ),
      ],
    );
  }
}
