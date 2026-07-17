import 'package:equatable/equatable.dart';

import '../entity/daily_revenue_confirmation_dto.dart';

sealed class BranchDashboardEvent extends Equatable {
  const BranchDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class BranchDashboardFetchRequested extends BranchDashboardEvent {
  final String trendPeriod;

  const BranchDashboardFetchRequested({this.trendPeriod = 'month'});

  @override
  List<Object?> get props => [trendPeriod];
}

final class BranchDashboardPeriodChanged extends BranchDashboardEvent {
  final String trendPeriod;

  const BranchDashboardPeriodChanged(this.trendPeriod);

  @override
  List<Object?> get props => [trendPeriod];
}

final class BranchDashboardSearchChanged extends BranchDashboardEvent {
  final String query;

  const BranchDashboardSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class DailyRevenueConfirmationSubmitted extends BranchDashboardEvent {
  final ConfirmDailyRevenueRequestDto request;

  const DailyRevenueConfirmationSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
