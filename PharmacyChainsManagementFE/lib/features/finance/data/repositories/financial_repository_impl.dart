import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/financial_repository.dart';
import '../models/export_criteria_model.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  final Dio dio;

  const FinancialRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, Uint8List>> exportFinancialReport(ExportCriteriaModel criteria) async {
    try {
      final response = await dio.post<List<int>>(
        '/api/finance/export',
        data: criteria.toJson(),
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Right(Uint8List.fromList(response.data!));
      } else if (response.statusCode == 404) {
        return const Left(ServerFailure('No Data Found'));
      } else {
        return const Left(ServerFailure('Generation Failed'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('No Data Found'));
      }
      return const Left(ServerFailure('Generation Failed'));
    } catch (e) {
      return const Left(ServerFailure('Generation Failed'));
    }
  }
}
