import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/control/branch_dashboard_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/control/branch_dashboard_event.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/control/branch_dashboard_state.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/entity/branch_dashboard_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/entity/daily_revenue_confirmation_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_dashboard/network/branch_dashboard_api_client.dart';

class MockBranchDashboardApiClient extends Mock
    implements BranchDashboardApiClient {}

BranchDashboardDto _dashboard({
  DailyRevenueConfirmationDto? confirmation,
  double todayRevenue = 1500,
}) => BranchDashboardDto(
  branchId: 'branch-01',
  branchName: 'Central Pharmacy',
  metrics: DashboardMetricDto(
    todayRevenue: todayRevenue,
    revenueChangePercent: 12.5,
    activeStaff: 2,
    totalStaff: 3,
    stockAlerts: 1,
    branchEfficiencyPercent: 91,
  ),
  revenueTrend: [
    RevenuePointDto(date: DateTime(2026, 7, 18), revenue: 1200),
    RevenuePointDto(date: DateTime(2026, 7, 19), revenue: todayRevenue),
  ],
  topStaff: const [
    DashboardStaffDto(
      staffId: 'staff-01',
      fullName: 'Alice Nguyen',
      roleName: 'Pharmacist',
      salesRevenue: 900,
    ),
    DashboardStaffDto(
      staffId: 'staff-02',
      fullName: 'Bob Tran',
      roleName: 'Cashier',
      salesRevenue: 600,
    ),
  ],
  inventoryAlerts: const [
    DashboardInventoryDto(
      medicineId: 'medicine-01',
      sku: 'SKU-CRITICAL',
      medicineName: 'Critical Medicine',
      category: 'Pain Relief',
      currentStock: 2,
      reorderPoint: 10,
      status: 'CRITICAL',
    ),
    DashboardInventoryDto(
      medicineId: 'medicine-02',
      sku: 'SKU-NORMAL',
      medicineName: 'Normal Medicine',
      category: 'Vitamin',
      currentStock: 50,
      reorderPoint: 10,
      status: 'NORMAL',
    ),
  ],
  todayRevenueConfirmation: confirmation,
);

DailyRevenueConfirmationDto _confirmation({
  double difference = 0,
  String? reason,
}) => DailyRevenueConfirmationDto(
  confirmationId: 'confirmation-01',
  revenueDate: DateTime(2026, 7, 19),
  systemAmount: 1500,
  actualCash: difference == 0 ? 1000 : 900,
  actualBankTransfer: 500,
  actualOther: 0,
  actualAmount: difference == 0 ? 1500 : 1400,
  difference: difference,
  isMatched: difference == 0,
  confirmedAt: DateTime(2026, 7, 19, 18),
  differenceReason: reason,
);

void main() {
  late MockBranchDashboardApiClient apiClient;

  setUp(() {
    apiClient = MockBranchDashboardApiClient();
  });

  group('UC09 - View Branch Dashboard', () {
    test('ST-01: initial state should be BranchDashboardInitial', () {
      final bloc = BranchDashboardBloc(apiClient);
      expect(bloc.state, const BranchDashboardInitial());
      bloc.close();
    });

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'HP-01: should expose all assigned-branch dashboard metrics when fetch succeeds',
      build: () {
        when(
          () => apiClient.fetchDashboard(trendPeriod: 'month'),
        ).thenAnswer((_) async => _dashboard());
        return BranchDashboardBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchDashboardFetchRequested()),
      expect: () => [
        const BranchDashboardLoading(),
        isA<BranchDashboardLoadSuccess>()
            .having(
              (state) => state.dashboard.metrics.todayRevenue,
              'today revenue',
              1500,
            )
            .having(
              (state) => state.dashboard.metrics.activeStaff,
              'active staff',
              2,
            )
            .having(
              (state) => state.dashboard.metrics.totalStaff,
              'total staff',
              3,
            )
            .having(
              (state) => state.dashboard.metrics.stockAlerts,
              'stock alerts',
              1,
            )
            .having(
              (state) => state.dashboard.revenueTrend.length,
              'trend points',
              2,
            )
            .having((state) => state.visibleStaff.length, 'top staff', 2)
            .having(
              (state) => state.visibleInventory.length,
              'inventory alerts',
              2,
            ),
      ],
      verify: (_) {
        verify(() => apiClient.fetchDashboard(trendPeriod: 'month')).called(1);
      },
    );

    for (final period in ['month', 'quarter', 'year']) {
      blocTest<BranchDashboardBloc, BranchDashboardState>(
        'EP-01: should reload revenue trend for $period period',
        build: () {
          when(
            () => apiClient.fetchDashboard(trendPeriod: period),
          ).thenAnswer((_) async => _dashboard());
          return BranchDashboardBloc(apiClient);
        },
        act: (bloc) => bloc.add(BranchDashboardPeriodChanged(period)),
        expect: () => [
          const BranchDashboardLoading(),
          isA<BranchDashboardLoadSuccess>().having(
            (state) => state.trendPeriod,
            'trend period',
            period,
          ),
        ],
        verify: (_) {
          verify(() => apiClient.fetchDashboard(trendPeriod: period)).called(1);
        },
      );
    }

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'DT-01: should filter top staff case-insensitively by name',
      build: () => BranchDashboardBloc(apiClient),
      seed: () => BranchDashboardLoadSuccess(
        dashboard: _dashboard(),
        visibleStaff: _dashboard().topStaff,
        visibleInventory: _dashboard().inventoryAlerts,
      ),
      act: (bloc) => bloc.add(const BranchDashboardSearchChanged('  ALICE  ')),
      expect: () => [
        isA<BranchDashboardLoadSuccess>()
            .having(
              (state) => state.visibleStaff.single.fullName,
              'staff',
              'Alice Nguyen',
            )
            .having((state) => state.visibleInventory, 'inventory', isEmpty),
      ],
      verify: (_) => verifyNever(
        () => apiClient.fetchDashboard(trendPeriod: any(named: 'trendPeriod')),
      ),
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'DT-02: should toggle critical inventory filter on and back off',
      build: () => BranchDashboardBloc(apiClient),
      seed: () => BranchDashboardLoadSuccess(
        dashboard: _dashboard(),
        visibleStaff: _dashboard().topStaff,
        visibleInventory: _dashboard().inventoryAlerts,
      ),
      act: (bloc) {
        bloc
          ..add(const BranchDashboardAlertsFilterToggled())
          ..add(const BranchDashboardAlertsFilterToggled());
      },
      expect: () => [
        isA<BranchDashboardLoadSuccess>()
            .having(
              (state) => state.criticalAlertsOnly,
              'critical only',
              isTrue,
            )
            .having(
              (state) => state.visibleInventory.single.status,
              'status',
              'CRITICAL',
            ),
        isA<BranchDashboardLoadSuccess>()
            .having(
              (state) => state.criticalAlertsOnly,
              'critical only',
              isFalse,
            )
            .having((state) => state.visibleInventory.length, 'all alerts', 2),
      ],
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'ST-I1: search and alert filter should be ignored before dashboard is loaded',
      build: () => BranchDashboardBloc(apiClient),
      act: (bloc) {
        bloc
          ..add(const BranchDashboardSearchChanged('Alice'))
          ..add(const BranchDashboardAlertsFilterToggled());
      },
      expect: () => <BranchDashboardState>[],
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'SP-01: should emit server message when dashboard API returns a known error',
      build: () {
        when(() => apiClient.fetchDashboard(trendPeriod: 'month')).thenThrow(
          const BranchManagerServerException('dashboard unavailable'),
        );
        return BranchDashboardBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchDashboardFetchRequested()),
      expect: () => [
        const BranchDashboardLoading(),
        const BranchDashboardLoadFailure('dashboard unavailable'),
      ],
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'EG-01: should emit generic load failure for an unexpected parsing error',
      build: () {
        when(
          () => apiClient.fetchDashboard(trendPeriod: 'month'),
        ).thenThrow(const FormatException('bad json'));
        return BranchDashboardBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchDashboardFetchRequested()),
      expect: () => [
        const BranchDashboardLoading(),
        isA<BranchDashboardLoadFailure>(),
      ],
    );
  });

  group('UC36 - Confirm Daily Revenue', () {
    final matchedRequest = const ConfirmDailyRevenueRequestDto(
      actualCash: 1000,
      actualBankTransfer: 500,
      actualOther: 0,
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'HP-01: should store confirmation once and refresh dashboard status',
      build: () {
        when(
          () => apiClient.confirmDailyRevenue(matchedRequest),
        ).thenAnswer((_) async => _confirmation());
        when(
          () => apiClient.fetchDashboard(trendPeriod: 'month'),
        ).thenAnswer((_) async => _dashboard(confirmation: _confirmation()));
        return BranchDashboardBloc(apiClient);
      },
      seed: () => BranchDashboardLoadSuccess(
        dashboard: _dashboard(),
        visibleStaff: _dashboard().topStaff,
        visibleInventory: _dashboard().inventoryAlerts,
      ),
      act: (bloc) =>
          bloc.add(DailyRevenueConfirmationSubmitted(matchedRequest)),
      expect: () => [
        isA<DailyRevenueConfirmationSuccess>()
            .having((state) => state.confirmation.isMatched, 'matched', isTrue)
            .having(
              (state) =>
                  state.dashboard.todayRevenueConfirmation?.confirmationId,
              'stored confirmation',
              'confirmation-01',
            )
            .having(
              (state) => state.dashboard.metrics.todayRevenue,
              'invoice revenue remains unchanged',
              1500,
            ),
      ],
      verify: (_) {
        verify(() => apiClient.confirmDailyRevenue(matchedRequest)).called(1);
        verify(() => apiClient.fetchDashboard(trendPeriod: 'month')).called(1);
      },
    );

    final mismatchRequest = const ConfirmDailyRevenueRequestDto(
      actualCash: 900,
      actualBankTransfer: 500,
      actualOther: 0,
      differenceReason: 'Cash drawer is short',
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'DT-01: should preserve required reason when actual receipts differ',
      build: () {
        final result = _confirmation(
          difference: -100,
          reason: 'Cash drawer is short',
        );
        when(
          () => apiClient.confirmDailyRevenue(mismatchRequest),
        ).thenAnswer((_) async => result);
        when(
          () => apiClient.fetchDashboard(trendPeriod: 'month'),
        ).thenAnswer((_) async => _dashboard(confirmation: result));
        return BranchDashboardBloc(apiClient);
      },
      seed: () => BranchDashboardLoadSuccess(
        dashboard: _dashboard(),
        visibleStaff: _dashboard().topStaff,
        visibleInventory: _dashboard().inventoryAlerts,
      ),
      act: (bloc) =>
          bloc.add(DailyRevenueConfirmationSubmitted(mismatchRequest)),
      expect: () => [
        isA<DailyRevenueConfirmationSuccess>()
            .having(
              (state) => state.confirmation.difference,
              'difference',
              -100,
            )
            .having(
              (state) => state.confirmation.differenceReason,
              'reason',
              'Cash drawer is short',
            ),
      ],
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'SP-01: should surface duplicate-confirmation error from server',
      build: () {
        when(() => apiClient.confirmDailyRevenue(matchedRequest)).thenThrow(
          const BranchManagerServerException(
            'Revenue has already been confirmed for this date.',
          ),
        );
        return BranchDashboardBloc(apiClient);
      },
      seed: () => BranchDashboardLoadSuccess(
        dashboard: _dashboard(),
        visibleStaff: _dashboard().topStaff,
        visibleInventory: _dashboard().inventoryAlerts,
      ),
      act: (bloc) =>
          bloc.add(DailyRevenueConfirmationSubmitted(matchedRequest)),
      expect: () => [
        const BranchDashboardLoadFailure(
          'Revenue has already been confirmed for this date.',
        ),
      ],
      verify: (_) => verifyNever(
        () => apiClient.fetchDashboard(trendPeriod: any(named: 'trendPeriod')),
      ),
    );

    blocTest<BranchDashboardBloc, BranchDashboardState>(
      'ST-I1: confirmation should be ignored before dashboard is loaded',
      build: () => BranchDashboardBloc(apiClient),
      act: (bloc) =>
          bloc.add(DailyRevenueConfirmationSubmitted(matchedRequest)),
      expect: () => <BranchDashboardState>[],
      verify: (_) =>
          verifyNever(() => apiClient.confirmDailyRevenue(matchedRequest)),
    );
  });
}
