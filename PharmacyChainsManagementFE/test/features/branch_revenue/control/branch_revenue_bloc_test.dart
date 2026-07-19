import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/constants/branch_manager_app_strings.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_event.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_state.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/entity/branch_revenue_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/network/branch_revenue_api_client.dart';

class MockBranchRevenueApiClient extends Mock implements BranchRevenueApiClient {}

void main() {
  late MockBranchRevenueApiClient mockApiClient;
  late BranchRevenueBloc sut;

  final tRevenueDto = BranchRevenueDto(
    branchId: 'B1',
    fromDate: DateTime(2023, 1, 1),
    toDate: DateTime(2023, 1, 31),
    totalRevenue: 1000,
    totalInvoices: 10,
    grossMarginPercent: 20.0,
    revenueTrend: const [],
    categoryRevenue: const [],
    performanceByTime: const [],
    paymentMethods: const [],
  );

  setUp(() {
    mockApiClient = MockBranchRevenueApiClient();
    sut = BranchRevenueBloc(mockApiClient);
  });

  tearDown(() {
    sut.close();
  });

  group('BranchRevenueBloc - FetchRequested', () {
    test('initial state should be BranchRevenueInitial', () {
      expect(sut.state, const BranchRevenueInitial());
    });

    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'HP-01: should emit [Loading, LoadSuccess] when fetch succeeds',
      build: () {
        when(() => mockApiClient.fetchRevenue(
              period: any(named: 'period'),
              fromDate: any(named: 'fromDate'),
              toDate: any(named: 'toDate'),
            )).thenAnswer((_) async => tRevenueDto);
        return sut;
      },
      act: (bloc) => bloc.add(const BranchRevenueFetchRequested(period: 'daily')),
      expect: () => [
        const BranchRevenueLoading(),
        BranchRevenueLoadSuccess(
          revenue: tRevenueDto,
          period: 'daily',
          visiblePerformance: const [],
        ),
      ],
      verify: (_) {
        verify(() => mockApiClient.fetchRevenue(period: 'daily')).called(1);
      },
    );

    // ═══════════════════════════════════════════════════
    // SAD PATH & EXCEPTION HANDLING
    // ═══════════════════════════════════════════════════
    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'SP-01: should emit [Loading, LoadFailure] when API throws BranchManagerAppException',
      build: () {
        when(() => mockApiClient.fetchRevenue(
              period: any(named: 'period'),
              fromDate: any(named: 'fromDate'),
              toDate: any(named: 'toDate'),
            )).thenThrow(const BranchManagerServerException('Server Error'));
        return sut;
      },
      act: (bloc) => bloc.add(const BranchRevenueFetchRequested(period: 'daily')),
      expect: () => [
        const BranchRevenueLoading(),
        const BranchRevenueLoadFailure('Server Error'),
      ],
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'EH-01: should emit [Loading, LoadFailure] with default string when unknown exception occurs',
      build: () {
        when(() => mockApiClient.fetchRevenue(
              period: any(named: 'period'),
              fromDate: any(named: 'fromDate'),
              toDate: any(named: 'toDate'),
            )).thenThrow(Exception('Unknown Error'));
        return sut;
      },
      act: (bloc) => bloc.add(const BranchRevenueFetchRequested(period: 'daily')),
      expect: () => [
        const BranchRevenueLoading(),
        const BranchRevenueLoadFailure(AppStrings.dataCannotLoad),
      ],
    );

    // ═══════════════════════════════════════════════════
    // EQUIVALENCE PARTITIONING & BOUNDARY
    // ═══════════════════════════════════════════════════
    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'EP/BVA: should pass fromDate and toDate correctly for custom period',
      build: () {
        when(() => mockApiClient.fetchRevenue(
              period: any(named: 'period'),
              fromDate: any(named: 'fromDate'),
              toDate: any(named: 'toDate'),
            )).thenAnswer((_) async => tRevenueDto);
        return sut;
      },
      act: (bloc) => bloc.add(BranchRevenueFetchRequested(
        period: 'custom',
        fromDate: DateTime(2023, 1, 1),
        toDate: DateTime(2023, 1, 31),
      )),
      expect: () => [
        const BranchRevenueLoading(),
        BranchRevenueLoadSuccess(
          revenue: tRevenueDto,
          period: 'custom',
          visiblePerformance: const [],
        ),
      ],
      verify: (_) {
        verify(() => mockApiClient.fetchRevenue(
              period: 'custom',
              fromDate: DateTime(2023, 1, 1),
              toDate: DateTime(2023, 1, 31),
            )).called(1);
      },
    );
  });
}
