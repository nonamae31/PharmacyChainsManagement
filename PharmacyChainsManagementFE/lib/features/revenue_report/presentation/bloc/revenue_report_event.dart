import 'package:equatable/equatable.dart';

abstract class RevenueReportEvent extends Equatable {
  const RevenueReportEvent();

  @override
  List<Object?> get props => [];
}

class FetchRevenueReportEvent extends RevenueReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FetchRevenueReportEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
