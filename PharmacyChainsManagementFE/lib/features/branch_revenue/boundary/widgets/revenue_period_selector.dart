import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_section_card.dart';

class RevenuePeriodSelector extends StatelessWidget {
  final String period;
  final DateTime fromDate;
  final DateTime toDate;
  final ValueChanged<String> onPeriodSelected;

  const RevenuePeriodSelector({
    super.key,
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final from = localizations.formatMediumDate(fromDate);
    final to = localizations.formatMediumDate(toDate);
    final dateLabel = fromDate == toDate
        ? from
        : '$from${AppStrings.dateRangeSeparator}$to';
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              const _PeriodHeading(),
              Chip(
                avatar: const Icon(Icons.date_range_outlined),
                label: Text(dateLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text(AppStrings.daily)),
                ButtonSegment(value: 'weekly', label: Text(AppStrings.weekly)),
                ButtonSegment(
                  value: 'monthly',
                  label: Text(AppStrings.monthly),
                ),
                ButtonSegment(value: 'custom', label: Text(AppStrings.custom)),
              ],
              selected: {period},
              onSelectionChanged: (selection) =>
                  onPeriodSelected(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodHeading extends StatelessWidget {
  const _PeriodHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.reportingPeriod, style: AppTextStyles.sectionTitle),
        SizedBox(height: AppSpacing.xxs),
        Text(AppStrings.reportingPeriodSubtitle, style: AppTextStyles.caption),
      ],
    );
  }
}
