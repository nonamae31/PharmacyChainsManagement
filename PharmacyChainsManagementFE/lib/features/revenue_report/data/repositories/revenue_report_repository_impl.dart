import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/exceptions.dart';
import '../../domain/entities/revenue_report_request.dart';
import '../../domain/entities/revenue_report_response.dart';
import '../../domain/repositories/revenue_report_repository.dart';
import '../datasources/revenue_report_remote_datasource.dart';
import '../models/revenue_report_request_model.dart';

class RevenueReportRepositoryImpl implements RevenueReportRepository {
  final RevenueReportRemoteDataSource remoteDataSource;

  RevenueReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RevenueReportResponse>> generateRevenueReport(
      RevenueReportRequest request) async {
    try {
      final requestModel = RevenueReportRequestModel(
        fromDate: request.fromDate,
        toDate: request.toDate,
        branchId: request.branchId,
      );
      final result = await remoteDataSource.generateRevenueReport(requestModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
