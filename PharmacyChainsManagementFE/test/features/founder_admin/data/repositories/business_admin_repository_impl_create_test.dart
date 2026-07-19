import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/repositories/business_admin_repository_impl.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/models/business_admin_request_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BusinessAdminRepositoryImpl sut;

  const tRequest = BusinessAdminRequestModel(
    fullName: 'John Doe',
    email: 'john@example.com',
    phone: '0123456789',
  );

  setUp(() {
    mockDio = MockDio();
    sut = BusinessAdminRepositoryImpl(dioOverride: mockDio);
  });

  group('createBusinessAdmin', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    test('HP-01: should complete successfully when API returns 200', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: {'message': 'Success'},
        ),
      );

      // Act
      await sut.createBusinessAdmin(tRequest);

      // Assert
      verify(() => mockDio.post('/api/v1/business-admin', data: {
            'fullName': tRequest.fullName,
            'email': tRequest.email,
            'phone': tRequest.phone,
          })).called(1);
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH & EXCEPTION HANDLING
    // ═══════════════════════════════════════════════════
    test('SP-01: should throw Exception when API returns non-200 status code', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 400,
          data: {'message': 'Email already exists'},
        ),
      );

      // Act & Assert
      expect(
        () => sut.createBusinessAdmin(tRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Email already exists'))),
      );
    });

    test('SP-02: should throw Exception with default message when API returns non-200 without message', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 500,
          data: {},
        ),
      );

      // Act & Assert
      expect(
        () => sut.createBusinessAdmin(tRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Tạo Business Admin thất bại.'))),
      );
    });

    test('EH-01: should throw Exception when DioException occurs with response data', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/business-admin'),
            statusCode: 409,
            data: {'message': 'Conflict'},
          ),
        ),
      );

      // Act & Assert
      expect(
        () => sut.createBusinessAdmin(tRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Conflict'))),
      );
    });

    test('EH-02: should throw Exception when DioException occurs without response', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          message: 'Connection timeout',
        ),
      );

      // Act & Assert
      expect(
        () => sut.createBusinessAdmin(tRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Connection timeout'))),
      );
    });

    test('EH-03: should throw Exception for unknown errors', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        const FormatException('Bad format'),
      );

      // Act & Assert
      expect(
        () => sut.createBusinessAdmin(tRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Lỗi không xác định: FormatException: Bad format'))),
      );
    });

    // ═══════════════════════════════════════════════════
    // ERROR GUESSING
    // ═══════════════════════════════════════════════════
    test('EG-01: should handle large payload without crashing', () async {
      // Arrange
      final largeRequest = BusinessAdminRequestModel(
        fullName: 'A' * 10000,
        email: 'test@example.com',
        phone: '1' * 1000,
      );
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: {'message': 'Success'},
        ),
      );

      // Act
      await sut.createBusinessAdmin(largeRequest);

      // Assert
      verify(() => mockDio.post('/api/v1/business-admin', data: {
            'fullName': largeRequest.fullName,
            'email': largeRequest.email,
            'phone': largeRequest.phone,
          })).called(1);
    });

    test('EG-02: should handle special characters and emojis correctly', () async {
      // Arrange
      const specialRequest = BusinessAdminRequestModel(
        fullName: 'Nguyễn Văn A 🚀 !@#',
        email: 'test+alias@example.com',
        phone: '+84912345678',
      );
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: {'message': 'Success'},
        ),
      );

      // Act
      await sut.createBusinessAdmin(specialRequest);

      // Assert
      verify(() => mockDio.post('/api/v1/business-admin', data: {
            'fullName': specialRequest.fullName,
            'email': specialRequest.email,
            'phone': specialRequest.phone,
          })).called(1);
    });
  });
}
