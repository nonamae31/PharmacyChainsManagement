import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:PharmacyChainsManagementFE/core/error/failures.dart';
import 'package:PharmacyChainsManagementFE/features/finance/data/models/export_criteria_model.dart';
import 'package:PharmacyChainsManagementFE/features/finance/data/repositories/financial_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late FinancialRepositoryImpl repository;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    repository = FinancialRepositoryImpl(dio: mockDio);
  });

  group('FinancialRepositoryImpl - exportFinancialReport', () {
    final tStartDate = DateTime.utc(2023, 1, 1);
    final tEndDate = DateTime.utc(2023, 1, 31);
    final tCriteria = ExportCriteriaModel(
      branchId: 'B001',
      startDate: tStartDate,
      endDate: tEndDate,
      format: 'PDF',
    );
    final tBytes = Uint8List.fromList([1, 2, 3]);

    test('should return Uint8List when the response is successful (200)', () async {
      // Arrange
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<List<int>>(
            requestOptions: RequestOptions(path: '/api/finance/export'),
            statusCode: 200,
            data: tBytes,
          ));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, Right(tBytes));
      verify(() => mockDio.post<List<int>>(
            '/api/finance/export',
            data: tCriteria.toJson(),
            options: any(named: 'options'),
          )).called(1);
    });

    test('should return ServerFailure(No Data Found) when status code is 404', () async {
      // Arrange
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<List<int>>(
            requestOptions: RequestOptions(path: '/api/finance/export'),
            statusCode: 404,
            data: null,
          ));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, const Left(ServerFailure('No Data Found')));
    });

    test('should return ServerFailure(Generation Failed) on non-200 non-404 status', () async {
      // Arrange
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<List<int>>(
            requestOptions: RequestOptions(path: '/api/finance/export'),
            statusCode: 500,
            data: null,
          ));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, const Left(ServerFailure('Generation Failed')));
    });

    test('should return ServerFailure when DioException occurs with 404', () async {
      // Arrange
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 404,
            ),
          ));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, const Left(ServerFailure('No Data Found')));
    });

    test('should handle DioException with encoded error message in data', () async {
      // Arrange
      final errorMessageBytes = utf8.encode('Custom Server Error');
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 400,
              data: errorMessageBytes,
            ),
          ));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, const Left(ServerFailure('Custom Server Error')));
    });

    test('should catch generic exceptions and return ServerFailure', () async {
      // Arrange
      when(() => mockDio.post<List<int>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.exportFinancialReport(tCriteria);

      // Assert
      expect(result, const Left(ServerFailure('Exception: Unexpected error')));
    });
  });
}
