import 'package:equatable/equatable.dart';

import '../entity/branch_revenue_dto.dart';

sealed class BranchRevenueState extends Equatable {
  const BranchRevenueState();

  @override
  List<Object?> get props => [];
}

final class BranchRevenueInitial extends BranchRevenueState {
  const BranchRevenueInitial();
}

final class BranchRevenueLoading extends BranchRevenueState {
  const BranchRevenueLoading();
}

class BranchRevenueLoadSuccess extends BranchRevenueState {
  final BranchRevenueDto revenue;
  final String period;
  final List<TimeBlockPerformanceDto> visiblePerformance;

  const BranchRevenueLoadSuccess({
    required this.revenue,
    required this.period,
    required this.visiblePerformance,
  });

  @override
  List<Object?> get props => [revenue, period, visiblePerformance];
}

final class BranchRevenueExportSuccess extends BranchRevenueLoadSuccess {
  final List<int> bytes;

  const BranchRevenueExportSuccess({
    required super.revenue,
    required super.period,
    required super.visiblePerformance,
    required this.bytes,
  });

  @override
  List<Object?> get props => [...super.props, bytes];
}

final class BranchRevenueLoadFailure extends BranchRevenueState {
  final String message;

  const BranchRevenueLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
