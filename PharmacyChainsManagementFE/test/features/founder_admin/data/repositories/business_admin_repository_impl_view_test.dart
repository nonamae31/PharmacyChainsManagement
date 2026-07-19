import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/repositories/business_admin_repository_impl.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/models/business_admin_model.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/entities/business_admin_entity.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BusinessAdminRepositoryImpl sut;

  final tBusinessAdminModelList = [
    const BusinessAdminModel(
      id: '1',
      name: 'Admin One',
      email: 'admin1@test.com',
      status: 'Active',
      phone: '0123456789',
    ),
  ];

  final tJsonResponse = {
    'data': [
      {
        'id': '1',
        'name': 'Admin One',
        'email': 'admin1@test.com',
        'status': 'Active',
        'phone': '0123456789',
      }
    ]
  };

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() async {
    // Clear storage before each test
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    
    mockDio = MockDio();
    sut = BusinessAdminRepositoryImpl(dioOverride: mockDio);
  });

  group('getBusinessAdmins', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH & CACHING
    // ═══════════════════════════════════════════════════
    test('HP-01: should return remote data when cache is empty and call API', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: tJsonResponse,
        ),
      );

      // Act
      final result = await sut.getBusinessAdmins(forceRefresh: false);

      // Assert
      expect(result, isA<List<BusinessAdminEntity>>());
      expect(result, equals(tBusinessAdminModelList));
      verify(() => mockDio.get('/api/v1/business-admin')).called(1);
    });

    test('HP-02: should return cached data when cache exists and forceRefresh is false, without calling API', () async {
      // Arrange
      const storage = FlutterSecureStorage();
      await storage.write(
        key: 'BUSINESS_ADMINS_CACHE', 
        value: jsonEncode(tBusinessAdminModelList.map((e) => e.toJson()).toList()),
      );

      // Act
      final result = await sut.getBusinessAdmins(forceRefresh: false);

      // Assert
      expect(result, equals(tBusinessAdminModelList));
      verifyNever(() => mockDio.get(any()));
    });

    test('HP-03: should bypass cache and call API when forceRefresh is true', () async {
      // Arrange
      const storage = FlutterSecureStorage();
      await storage.write(
        key: 'BUSINESS_ADMINS_CACHE', 
        value: jsonEncode(tBusinessAdminModelList.map((e) => e.toJson()).toList()),
      );

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: tJsonResponse,
        ),
      );

      // Act
      final result = await sut.getBusinessAdmins(forceRefresh: true);

      // Assert
      expect(result, equals(tBusinessAdminModelList));
      verify(() => mockDio.get('/api/v1/business-admin')).called(1);
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH & EXCEPTION HANDLING
    // ═══════════════════════════════════════════════════
    test('SP-01: should throw Exception when API returns non-200', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
      );

      // Act & Assert
      expect(() => sut.getBusinessAdmins(forceRefresh: true), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Server error'))));
    });

    test('EH-01: should handle DioException network error gracefully', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          message: 'Connection timeout',
        ),
      );

      // Act & Assert
      expect(() => sut.getBusinessAdmins(forceRefresh: true), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Lỗi kết nối tới server'))));
    });

    // ═══════════════════════════════════════════════════
    // ERROR GUESSING
    // ═══════════════════════════════════════════════════
    test('EG-01: should fallback to API when cached JSON is malformed', () async {
      // Arrange
      const storage = FlutterSecureStorage();
      await storage.write(key: 'BUSINESS_ADMINS_CACHE', value: 'invalid_json_string');

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: tJsonResponse,
        ),
      );

      // Act
      final result = await sut.getBusinessAdmins(forceRefresh: false);

      // Assert
      expect(result, equals(tBusinessAdminModelList));
      verify(() => mockDio.get('/api/v1/business-admin')).called(1);
    });

    test('EG-02: should handle empty data array from API', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/business-admin'),
          statusCode: 200,
          data: {'data': []},
        ),
      );

      // Act
      final result = await sut.getBusinessAdmins(forceRefresh: true);

      // Assert
      expect(result, isEmpty);
    });
  });
}
