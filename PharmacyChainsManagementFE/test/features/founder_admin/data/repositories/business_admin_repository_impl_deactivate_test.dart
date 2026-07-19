import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/repositories/business_admin_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BusinessAdminRepositoryImpl sut;

  const tId = '123';

  setUp(() {
    mockDio = MockDio();
    sut = BusinessAdminRepositoryImpl(dioOverride: mockDio);
  });

  group('softDeleteBusinessAdmin', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    test('HP-01: should return Right(null) when API returns 200', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
          statusCode: 200,
          data: {'message': 'Success'},
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin(tId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockDio.delete('/api/v1/business-admin/$tId')).called(1);
    });

    test('HP-02: should return Right(null) when API returns 204 (No Content)', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
          statusCode: 204,
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin(tId);

      // Assert
      expect(result, const Right(null));
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH & EXCEPTION HANDLING
    // ═══════════════════════════════════════════════════
    test('SP-01: should return Left(ServerFailure) when API returns 400', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
          statusCode: 400,
          data: {'message': 'Deactivate failed'},
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin(tId);

      // Assert
      expect(result, const Left(ServerFailure('Deactivate failed')));
    });

    test('EH-01: should return Left(ServerFailure) when DioException occurs with response data', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
            statusCode: 404,
            data: {'message': 'Not Found'},
          ),
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin(tId);

      // Assert
      expect(result, const Left(ServerFailure('Not Found')));
    });

    test('EH-02: should return Left(ServerFailure) when DioException occurs without response', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/$tId'),
          message: 'Connection timeout',
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin(tId);

      // Assert
      expect(result, const Left(ServerFailure('Lỗi kết nối: Connection timeout')));
    });

    // ═══════════════════════════════════════════════════
    // ERROR GUESSING
    // ═══════════════════════════════════════════════════
    test('EG-01: should handle empty ID safely without crashing', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin/'),
          statusCode: 404,
          data: {'message': 'Not Found Route'},
        ),
      );

      // Act
      final result = await sut.softDeleteBusinessAdmin('');

      // Assert
      expect(result, const Left(ServerFailure('Not Found Route')));
    });
  });
}
