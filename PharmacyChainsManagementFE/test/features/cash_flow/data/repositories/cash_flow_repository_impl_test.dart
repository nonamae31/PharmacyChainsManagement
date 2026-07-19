import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/data/datasources/cash_flow_remote_datasource.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/data/models/cash_flow_model.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/data/repositories/cash_flow_repository_impl.dart';

class MockCashFlowRemoteDataSource extends Mock implements CashFlowRemoteDataSource {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockCashFlowRemoteDataSource mockRemoteDataSource;
  late MockFlutterSecureStorage mockSecureStorage;
  late CashFlowRepositoryImpl sut;

  final tCashFlowModel = CashFlowModel(
    totalInflow: 1000,
    totalOutflow: 500,
    netCashFlow: 500,
    dailyData: const [],
    recentTransactions: const [],
    liquidityForecasts: const [],
    budgetAllocations: const [],
  );

  setUp(() {
    mockRemoteDataSource = MockCashFlowRemoteDataSource();
    mockSecureStorage = MockFlutterSecureStorage();
    sut = CashFlowRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorage: mockSecureStorage,
    );
  });

  group('CashFlowRepositoryImpl - getCashFlow', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    test('HP-01: should return remote data and cache it when remote call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCashFlow(any(), any(), branchId: any(named: 'branchId')))
          .thenAnswer((_) async => tCashFlowModel);
      when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await sut.getCashFlow('2023-01-01', '2023-01-31');

      // Assert
      expect(result, equals(tCashFlowModel));
      verify(() => mockRemoteDataSource.getCashFlow('2023-01-01', '2023-01-31', branchId: null)).called(1);
      verify(() => mockSecureStorage.write(
            key: 'CACHED_CASH_FLOW_STATISTICS',
            value: jsonEncode(tCashFlowModel.toJson()),
          )).called(1);
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH
    // ═══════════════════════════════════════════════════
    test('SP-01: should return cached data when remote call fails and cache exists', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCashFlow(any(), any(), branchId: any(named: 'branchId')))
          .thenThrow(Exception('Server error'));
      when(() => mockSecureStorage.read(key: 'CACHED_CASH_FLOW_STATISTICS'))
          .thenAnswer((_) async => jsonEncode(tCashFlowModel.toJson()));

      // Act
      final result = await sut.getCashFlow('2023-01-01', '2023-01-31');

      // Assert
      expect(result, equals(tCashFlowModel));
      verify(() => mockRemoteDataSource.getCashFlow('2023-01-01', '2023-01-31', branchId: null)).called(1);
      verify(() => mockSecureStorage.read(key: 'CACHED_CASH_FLOW_STATISTICS')).called(1);
    });

    test('SP-02: should throw exception when remote call fails and no cache exists', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCashFlow(any(), any(), branchId: any(named: 'branchId')))
          .thenThrow(Exception('Server error'));
      when(() => mockSecureStorage.read(key: 'CACHED_CASH_FLOW_STATISTICS'))
          .thenAnswer((_) async => null);

      // Act
      final call = sut.getCashFlow;

      // Assert
      expect(() => call('2023-01-01', '2023-01-31'), throwsException);
    });
  });
}
