import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_api_client_base.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/entity/branch_revenue_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/network/branch_revenue_api_client.dart';

class MockBranchManagerApiClientBase extends Mock implements BranchManagerApiClientBase {}

void main() {
  late MockBranchManagerApiClientBase mockBaseClient;
  late BranchRevenueApiClient sut;

  final tJsonResponse = {
    'branchId': 'B1',
    'fromDate': '2023-01-01T00:00:00.000Z',
    'toDate': '2023-01-31T00:00:00.000Z',
    'totalRevenue': 1000.0,
    'totalInvoices': 10,
    'grossMarginPercent': 20.0,
    'revenueTrend': [],
    'categoryRevenue': [],
    'performanceByTime': [],
    'paymentMethods': [],
  };

  final tRevenueDto = BranchRevenueDto.fromJson(tJsonResponse);

  setUp(() {
    mockBaseClient = MockBranchManagerApiClientBase();
    sut = BranchRevenueApiClient(mockBaseClient);
  });

  group('BranchRevenueApiClient - fetchRevenue', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    test('HP-01: should return BranchRevenueDto when base client succeeds with 200', () async {
      // Arrange
      when(() => mockBaseClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/v1/branch-manager/revenue'),
            statusCode: 200,
            data: tJsonResponse,
          ));

      // Act
      final result = await sut.fetchRevenue(period: 'daily');

      // Assert
      expect(result, equals(tRevenueDto));
      verify(() => mockBaseClient.get(
            '/api/v1/branch-manager/revenue',
            queryParameters: {'period': 'daily'},
          )).called(1);
    });

    // ═══════════════════════════════════════════════════
    // EQUIVALENCE PARTITIONING & BOUNDARY
    // ═══════════════════════════════════════════════════
    test('EP/BVA: should format date parameters correctly', () async {
      // Arrange
      when(() => mockBaseClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/v1/branch-manager/revenue'),
            statusCode: 200,
            data: tJsonResponse,
          ));

      final fromDate = DateTime(2023, 5, 2);
      final toDate = DateTime(2023, 11, 25);

      // Act
      await sut.fetchRevenue(period: 'custom', fromDate: fromDate, toDate: toDate);

      // Assert
      verify(() => mockBaseClient.get(
            '/api/v1/branch-manager/revenue',
            queryParameters: {
              'period': 'custom',
              'fromDate': '2023-05-02',
              'toDate': '2023-11-25',
            },
          )).called(1);
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH & EXCEPTION HANDLING
    // ═══════════════════════════════════════════════════
    test('SP-01: should let exception propagate when base client throws BranchManagerAppException', () async {
      // Arrange
      when(() => mockBaseClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(const BranchManagerServerException('Server error'));

      // Act & Assert
      expect(
        () => sut.fetchRevenue(period: 'daily'),
        throwsA(isA<BranchManagerServerException>()),
      );
    });

    // ═══════════════════════════════════════════════════
    // ERROR GUESSING
    // ═══════════════════════════════════════════════════
    test('EG-01: should handle missing optional date fields gracefully', () async {
      // Arrange
      when(() => mockBaseClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/v1/branch-manager/revenue'),
            statusCode: 200,
            data: tJsonResponse,
          ));

      // Act
      await sut.fetchRevenue(period: 'monthly', fromDate: DateTime(2023, 1, 1)); // no toDate

      // Assert
      verify(() => mockBaseClient.get(
            '/api/v1/branch-manager/revenue',
            queryParameters: {
              'period': 'monthly',
              'fromDate': '2023-01-01',
            },
          )).called(1);
    });
  });
}
