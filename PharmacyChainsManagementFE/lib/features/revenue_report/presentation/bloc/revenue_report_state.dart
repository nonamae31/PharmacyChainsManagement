import 'package:equatable/equatable.dart';
import '../../domain/entities/revenue_report_response.dart';

abstract class RevenueReportState extends Equatable {
  const RevenueReportState();

  @override
  List<Object?> get props => [];
}

class RevenueReportInitial extends RevenueReportState {}

class RevenueReportLoading extends RevenueReportState {}

class RevenueReportLoaded extends RevenueReportState {
  final RevenueReportResponse report;

  const RevenueReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class RevenueReportError extends RevenueReportState {
  final String message;

  const RevenueReportError(this.message);

  @override
  List<Object?> get props => [message];
}
