import '../../domain/entities/revenue_report_request.dart';

class RevenueReportRequestModel extends RevenueReportRequest {
  const RevenueReportRequestModel({
    required super.fromDate,
    required super.toDate,
    required super.branchId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'branchId': branchId,
    };
  }
}
