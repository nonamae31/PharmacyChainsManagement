import '../../domain/entities/revenue_report_request.dart';

class RevenueReportRequestModel extends RevenueReportRequest {
  const RevenueReportRequestModel({
    required super.fromDate,
    required super.toDate,
    required super.branchId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromDate': "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
      'toDate': "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
      'branchId': branchId,
    };
  }
}
