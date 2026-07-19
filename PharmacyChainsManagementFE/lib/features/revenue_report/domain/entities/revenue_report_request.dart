import 'package:equatable/equatable.dart';

class RevenueReportRequest extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final String branchId;

  const RevenueReportRequest({
    required this.fromDate,
    required this.toDate,
    required this.branchId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, branchId];
}
