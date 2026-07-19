import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_report_request.dart';
import '../entities/revenue_report_response.dart';

abstract class RevenueReportRepository {
  Future<Either<Failure, RevenueReportResponse>> generateRevenueReport(
      RevenueReportRequest request);
}
