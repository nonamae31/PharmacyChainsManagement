import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/entity/branch_dashboard_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_event.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/control/branch_revenue_state.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/entity/branch_revenue_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_revenue/network/branch_revenue_api_client.dart';

class MockBranchRevenueApiClient extends Mock
    implements BranchRevenueApiClient {}

BranchRevenueDto _revenue({
  DateTime? fromDate,
  DateTime? toDate,
  double totalRevenue = 3000,
}) => BranchRevenueDto(
  branchId: 'branch-01',
  fromDate: fromDate ?? DateTime(2026, 7, 19),
  toDate: toDate ?? DateTime(2026, 7, 19),
  totalRevenue: totalRevenue,
  totalInvoices: 3,
  grossMarginPercent: 24.5,
  revenueTrend: [
    RevenuePointDto(date: DateTime(2026, 7, 19), revenue: totalRevenue),
  ],
  categoryRevenue: const [
    CategoryRevenueDto(
      category: 'Pain Relief',
      revenue: 1800,
      contributionPercent: 60,
    ),
    CategoryRevenueDto(
      category: 'Vitamin',
      revenue: 1200,
      contributionPercent: 40,
    ),
  ],
  performanceByTime: const [
    TimeBlockPerformanceDto(
      timeBlock: '08:00-12:00',
      transactions: 2,
      revenue: 2000,
      averageOrder: 1000,
      status: 'HIGH',
    ),
    TimeBlockPerformanceDto(
      timeBlock: '12:00-17:00',
      transactions: 1,
      revenue: 1000,
      averageOrder: 1000,
      status: 'NORMAL',
    ),
  ],
  paymentMethods: const [
    PaymentMethodRevenueDto(
      paymentMethod: 'CASH',
      transactions: 2,
      revenue: 2000,
      contributionPercent: 66.67,
    ),
    PaymentMethodRevenueDto(
      paymentMethod: 'BANK_TRANSFER',
      transactions: 1,
      revenue: 1000,
      contributionPercent: 33.33,
    ),
  ],
);

void main() {
  late MockBranchRevenueApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    apiClient = MockBranchRevenueApiClient();
  });

  group('UC10 - View and Export Branch Revenue Statistics', () {
    test('ST-01: initial state should be BranchRevenueInitial', () {
      final bloc = BranchRevenueBloc(apiClient);
      expect(bloc.state, const BranchRevenueInitial());
      bloc.close();
    });

    for (final period in ['daily', 'weekly', 'monthly']) {
      blocTest<BranchRevenueBloc, BranchRevenueState>(
        'EP-01: should load paid non-cancelled revenue for $period period',
        build: () {
          when(
            () => apiClient.fetchRevenue(
              period: period,
              fromDate: null,
              toDate: null,
            ),
          ).thenAnswer((_) async => _revenue());
          return BranchRevenueBloc(apiClient);
        },
        act: (bloc) => bloc.add(BranchRevenueFetchRequested(period: period)),
        expect: () => [
          const BranchRevenueLoading(),
          isA<BranchRevenueLoadSuccess>()
              .having((state) => state.period, 'period', period)
              .having(
                (state) => state.revenue.totalRevenue,
                'total revenue',
                3000,
              )
              .having(
                (state) => state.revenue.totalInvoices,
                'invoice count',
                3,
              )
              .having(
                (state) => state.revenue.categoryRevenue.length,
                'categories',
                2,
              )
              .having(
                (state) => state.visiblePerformance.length,
                'time blocks',
                2,
              )
              .having(
                (state) => state.revenue.paymentMethods.length,
                'payment methods',
                2,
              ),
        ],
        verify: (_) {
          verify(
            () => apiClient.fetchRevenue(
              period: period,
              fromDate: null,
              toDate: null,
            ),
          ).called(1);
        },
      );
    }

    final maxFrom = DateTime(2026, 1, 1);
    final maxTo = DateTime(2027, 1, 1);

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'BVA-01: should accept and forward a custom range of exactly 366 inclusive days',
      build: () {
        when(
          () => apiClient.fetchRevenue(
            period: 'custom',
            fromDate: maxFrom,
            toDate: maxTo,
          ),
        ).thenAnswer((_) async => _revenue(fromDate: maxFrom, toDate: maxTo));
        return BranchRevenueBloc(apiClient);
      },
      act: (bloc) => bloc.add(
        BranchRevenueFetchRequested(
          period: 'custom',
          fromDate: maxFrom,
          toDate: maxTo,
        ),
      ),
      expect: () => [
        const BranchRevenueLoading(),
        isA<BranchRevenueLoadSuccess>()
            .having((state) => state.revenue.fromDate, 'from date', maxFrom)
            .having((state) => state.revenue.toDate, 'to date', maxTo),
      ],
      verify: (_) {
        verify(
          () => apiClient.fetchRevenue(
            period: 'custom',
            fromDate: maxFrom,
            toDate: maxTo,
          ),
        ).called(1);
      },
    );

    final overLimitTo = DateTime(2027, 1, 2);

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'BVA-02: should surface API validation error for a 367-day custom range',
      build: () {
        when(
          () => apiClient.fetchRevenue(
            period: 'custom',
            fromDate: maxFrom,
            toDate: overLimitTo,
          ),
        ).thenThrow(
          const BranchManagerServerException(
            'Custom range cannot exceed 366 days.',
          ),
        );
        return BranchRevenueBloc(apiClient);
      },
      act: (bloc) => bloc.add(
        BranchRevenueFetchRequested(
          period: 'custom',
          fromDate: maxFrom,
          toDate: overLimitTo,
        ),
      ),
      expect: () => [
        const BranchRevenueLoading(),
        const BranchRevenueLoadFailure('Custom range cannot exceed 366 days.'),
      ],
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'SP-01: should preserve a known server error message',
      build: () {
        when(
          () => apiClient.fetchRevenue(
            period: 'daily',
            fromDate: null,
            toDate: null,
          ),
        ).thenThrow(const BranchManagerServerException('revenue unavailable'));
        return BranchRevenueBloc(apiClient);
      },
      act: (bloc) =>
          bloc.add(const BranchRevenueFetchRequested(period: 'daily')),
      expect: () => [
        const BranchRevenueLoading(),
        const BranchRevenueLoadFailure('revenue unavailable'),
      ],
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'EG-01: should emit generic failure for malformed response data',
      build: () {
        when(
          () => apiClient.fetchRevenue(
            period: 'daily',
            fromDate: null,
            toDate: null,
          ),
        ).thenThrow(const FormatException('bad json'));
        return BranchRevenueBloc(apiClient);
      },
      act: (bloc) =>
          bloc.add(const BranchRevenueFetchRequested(period: 'daily')),
      expect: () => [
        const BranchRevenueLoading(),
        isA<BranchRevenueLoadFailure>(),
      ],
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'HP-02: should export the currently selected custom period as CSV bytes',
      build: () {
        when(
          () => apiClient.exportRevenue(
            period: 'custom',
            fromDate: maxFrom,
            toDate: maxTo,
          ),
        ).thenAnswer((_) async => [105, 100, 44, 97, 109, 111, 117, 110, 116]);
        return BranchRevenueBloc(apiClient);
      },
      seed: () => BranchRevenueLoadSuccess(
        revenue: _revenue(fromDate: maxFrom, toDate: maxTo),
        period: 'custom',
        visiblePerformance: _revenue().performanceByTime,
      ),
      act: (bloc) => bloc.add(const BranchRevenueExportRequested()),
      expect: () => [
        isA<BranchRevenueExportSuccess>()
            .having((state) => state.period, 'period', 'custom')
            .having((state) => state.bytes, 'CSV bytes', isNotEmpty),
      ],
      verify: (_) {
        verify(
          () => apiClient.exportRevenue(
            period: 'custom',
            fromDate: maxFrom,
            toDate: maxTo,
          ),
        ).called(1);
      },
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'SP-02: should surface export error without returning corrupt bytes',
      build: () {
        when(
          () => apiClient.exportRevenue(
            period: 'daily',
            fromDate: null,
            toDate: null,
          ),
        ).thenThrow(const BranchManagerServerException('export failed'));
        return BranchRevenueBloc(apiClient);
      },
      seed: () => BranchRevenueLoadSuccess(
        revenue: _revenue(),
        period: 'daily',
        visiblePerformance: _revenue().performanceByTime,
      ),
      act: (bloc) => bloc.add(const BranchRevenueExportRequested()),
      expect: () => [const BranchRevenueLoadFailure('export failed')],
    );

    blocTest<BranchRevenueBloc, BranchRevenueState>(
      'ST-I1: export should be ignored before revenue is loaded',
      build: () => BranchRevenueBloc(apiClient),
      act: (bloc) => bloc.add(const BranchRevenueExportRequested()),
      expect: () => <BranchRevenueState>[],
      verify: (_) => verifyNever(
        () => apiClient.exportRevenue(
          period: any(named: 'period'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        ),
      ),
    );
  });
}
