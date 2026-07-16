import 'package:flutter/material.dart';

import '../../../../core/constants/branch_manager_app_strings.dart';
import '../../../../core/theme/branch_manager_app_theme.dart';
import '../../../../shared/shared_components/app_chart.dart';
import '../../../../shared/shared_components/app_empty_state.dart';
import '../../../../shared/shared_components/app_metric_card.dart';
import '../../../../shared/shared_components/app_mobile_detail_card.dart';
import '../../../../shared/shared_components/app_responsive_metric_grid.dart';
import '../../../../shared/shared_components/app_section_card.dart';
import '../../entity/staff_performance_dto.dart';

class StaffPerformanceContent extends StatelessWidget {
  final StaffPerformanceDto performance;

  const StaffPerformanceContent({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppResponsiveMetricGrid(
            children: [
              AppMetricCard(
                label: AppStrings.averageSalesTarget,
                value: _percent(performance.averageSalesTargetPercent),
                icon: Icons.trending_up,
              ),
              AppMetricCard(
                label: AppStrings.customerSatisfaction,
                value: performance.customerSatisfaction == null
                    ? AppStrings.unavailable
                    : '${performance.customerSatisfaction!.toStringAsFixed(1)}/5',
                icon: Icons.star_outline,
              ),
              AppMetricCard(
                label: AppStrings.teamAttendance,
                value: _percent(performance.teamAttendancePercent),
                icon: Icons.fact_check_outlined,
              ),
              _TopPerformerCard(topPerformer: performance.topPerformer),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _StaffMatrix(performance: performance),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth < AppSpacing.stackedPanelBreakpoint
                ? Column(
                    children: [
                      _TrendPanel(performance: performance),
                      const SizedBox(height: AppSpacing.md),
                      const _FeedbackPanel(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _TrendPanel(performance: performance)),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(child: _FeedbackPanel()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _percent(double? value) => value == null
      ? AppStrings.unavailable
      : '${value.toStringAsFixed(1)}${AppStrings.percentSymbol}';
}

class _TopPerformerCard extends StatelessWidget {
  final StaffPerformanceRowDto? topPerformer;

  const _TopPerformerCard({required this.topPerformer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.metricHeight,
      child: AppSectionCard(
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.topPerformer,
              style: AppTextStyles.metricLabel,
            ),
            const Spacer(),
            Text(
              topPerformer?.fullName ?? AppStrings.unavailable,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.surface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              topPerformer == null
                  ? AppStrings.unavailable
                  : '${AppStrings.salesRevenueLabel}: ${AppStrings.currencySymbol}${topPerformer!.salesRevenue.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.tealSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffMatrix extends StatelessWidget {
  final StaffPerformanceDto performance;

  const _StaffMatrix({required this.performance});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.staffPerformanceMatrix,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              Text(
                '${performance.staff.length} ${AppStrings.activeTeam}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (performance.staff.isEmpty)
            const AppEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint) {
                  return Column(
                    children: [
                      for (final staff in performance.staff) ...[
                        AppMobileDetailCard(
                          title: staff.fullName,
                          subtitle: staff.roleName,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.tealSoft,
                            child: Text(
                              staff.fullName.isEmpty ? '' : staff.fullName[0],
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          details: [
                            AppMobileDetailItem(
                              label: AppStrings.salesRevenueLabel,
                              value:
                                  '${AppStrings.currencySymbol}${staff.salesRevenue.toStringAsFixed(0)}',
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.salesTarget,
                              value: staff.salesTarget == null
                                  ? AppStrings.unavailable
                                  : '${AppStrings.currencySymbol}${staff.salesTarget!.toStringAsFixed(0)}',
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.targetProgress,
                              value: staff.targetProgressPercent == null
                                  ? AppStrings.unavailable
                                  : '${staff.targetProgressPercent!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.customerRating,
                              value:
                                  staff.customerRating?.toStringAsFixed(1) ??
                                  AppStrings.unavailable,
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.attendance,
                              value: staff.attendancePercent == null
                                  ? AppStrings.unavailable
                                  : '${staff.attendancePercent!.toStringAsFixed(0)}${AppStrings.percentSymbol}',
                            ),
                            AppMobileDetailItem(
                              label: AppStrings.performance,
                              value: staff.performanceScore == null
                                  ? AppStrings.unavailable
                                  : '${staff.performanceScore!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
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
                      DataColumn(label: Text(AppStrings.teamMember)),
                      DataColumn(label: Text(AppStrings.salesTarget)),
                      DataColumn(label: Text(AppStrings.targetProgress)),
                      DataColumn(label: Text(AppStrings.customerRating)),
                      DataColumn(label: Text(AppStrings.attendance)),
                      DataColumn(label: Text(AppStrings.performance)),
                    ],
                    rows: performance.staff
                        .map(
                          (staff) => DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: AppSpacing.md,
                                      backgroundColor: AppColors.tealSoft,
                                      child: Text(
                                        staff.fullName.isEmpty
                                            ? ''
                                            : staff.fullName[0],
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staff.fullName,
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          staff.roleName,
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${AppStrings.currencySymbol}${staff.salesRevenue.toStringAsFixed(0)} / ${staff.salesTarget == null ? AppStrings.unavailable : '${AppStrings.currencySymbol}${staff.salesTarget!.toStringAsFixed(0)}'}',
                                ),
                              ),
                              DataCell(
                                staff.targetProgressPercent == null
                                    ? const Text(AppStrings.unavailable)
                                    : SizedBox(
                                        width: AppSpacing.progressWidth,
                                        child: LinearProgressIndicator(
                                          value:
                                              (staff.targetProgressPercent! /
                                                      100)
                                                  .clamp(0.0, 1.0)
                                                  .toDouble(),
                                          color:
                                              staff.targetProgressPercent! < 70
                                              ? AppColors.danger
                                              : AppColors.primary,
                                          backgroundColor: AppColors.border,
                                        ),
                                      ),
                              ),
                              DataCell(
                                Text(
                                  staff.customerRating?.toStringAsFixed(1) ??
                                      AppStrings.unavailable,
                                ),
                              ),
                              DataCell(
                                Text(
                                  staff.attendancePercent == null
                                      ? AppStrings.unavailable
                                      : '${staff.attendancePercent!.toStringAsFixed(0)}${AppStrings.percentSymbol}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  staff.performanceScore == null
                                      ? AppStrings.unavailable
                                      : '${staff.performanceScore!.toStringAsFixed(1)}${AppStrings.percentSymbol}',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  final StaffPerformanceDto performance;

  const _TrendPanel({required this.performance});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.trendAnalysis,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          AppBarChart(
            values: performance.trend
                .map((item) => item.revenue)
                .toList(growable: false),
            color: AppColors.teal,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: AppColors.tealSoft,
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.managerInsightMessage,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel();

  @override
  Widget build(BuildContext context) {
    return const AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.recentFeedback, style: AppTextStyles.sectionTitle),
          SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.rate_review_outlined,
            color: AppColors.muted,
            size: AppSpacing.xxl,
          ),
          SizedBox(height: AppSpacing.md),
          Text(AppStrings.noFeedbackData, style: AppTextStyles.body),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: null,
              child: Text(AppStrings.viewAllReviews),
            ),
          ),
        ],
      ),
    );
  }
}
