import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_report_request.dart';
import '../entities/revenue_report_response.dart';
import '../repositories/revenue_report_repository.dart';

class GenerateRevenueReportUseCase {
  final RevenueReportRepository repository;

  GenerateRevenueReportUseCase(this.repository);

  Future<Either<Failure, RevenueReportResponse>> call(
      RevenueReportRequest request) async {
    return await repository.generateRevenueReport(request);
  }
}
