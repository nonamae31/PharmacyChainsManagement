import 'package:equatable/equatable.dart';

sealed class BranchRevenueEvent extends Equatable {
  const BranchRevenueEvent();

  @override
  List<Object?> get props => [];
}

final class BranchRevenueFetchRequested extends BranchRevenueEvent {
  final String period;
  final DateTime? fromDate;
  final DateTime? toDate;

  const BranchRevenueFetchRequested({required this.period, this.fromDate, this.toDate});

  @override
  List<Object?> get props => [period, fromDate, toDate];
}

final class BranchRevenueSearchChanged extends BranchRevenueEvent {
  final String query;

  const BranchRevenueSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class BranchRevenueExportRequested extends BranchRevenueEvent {
  const BranchRevenueExportRequested();
}
