import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/control/staff_performance_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/control/staff_performance_event.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/control/staff_performance_state.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/entity/staff_management_dto.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/entity/staff_payroll_dto.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/entity/staff_performance_dto.dart';
import 'package:pharmacy_chains_management_fe/features/staff_performance/network/staff_performance_api_client.dart';

class MockStaffPerformanceApiClient extends Mock
    implements StaffPerformanceApiClient {}

StaffPerformanceDto _performance() => StaffPerformanceDto(
  branchId: 'branch-01',
  averageSalesTargetPercent: 92,
  customerSatisfaction: 4.7,
  teamAttendancePercent: 96,
  topPerformer: _staffRows.first,
  staff: _staffRows,
  trend: const [StaffTrendPointDto(label: 'Jul', revenue: 5000)],
  recentFeedback: [
    StaffFeedbackDto(
      assessmentId: 'assessment-01',
      staffId: 'staff-01',
      staffName: 'Alice Nguyen',
      assessmentDate: DateTime(2026, 7, 18),
      performanceScore: 9,
      notes: 'Good service',
    ),
  ],
);

final _staffRows = [
  StaffPerformanceRowDto(
    staffId: 'staff-01',
    fullName: 'Alice Nguyen',
    email: 'alice@pharmacy.com',
    roleName: 'STAFF',
    status: 'ACTIVE',
    salesRevenue: 3000,
    assessmentDate: DateTime(2026, 7, 18),
    salesTarget: 2500,
    targetProgressPercent: 120,
    customerRating: 4.8,
    attendancePercent: 98,
    performanceScore: 9,
  ),
  const StaffPerformanceRowDto(
    staffId: 'staff-02',
    fullName: 'Bob Tran',
    email: 'bob@pharmacy.com',
    roleName: 'STAFF',
    status: 'INACTIVE',
    salesRevenue: 2000,
    assessmentDate: null,
    salesTarget: null,
    targetProgressPercent: null,
    customerRating: null,
    attendancePercent: null,
    performanceScore: null,
  ),
];

List<StaffShiftDto> _shifts({DateTime? weekStart}) {
  final monday = weekStart ?? DateTime(2026, 7, 20);
  return [
    StaffShiftDto(
      shiftId: 'shift-01',
      staffId: 'staff-01',
      staffName: 'Alice Nguyen',
      shiftDate: monday,
      startTime: const TimeOfDayValue(8, 0),
      endTime: const TimeOfDayValue(12, 0),
      status: 'SCHEDULED',
      notes: null,
      updatedAt: DateTime(2026, 7, 19),
      isRecurring: true,
    ),
  ];
}

StaffPayrollSummaryDto _payroll({DateTime? periodStart, DateTime? periodEnd}) =>
    StaffPayrollSummaryDto(
      branchId: 'branch-01',
      periodStart: periodStart ?? DateTime(2026, 7, 1),
      periodEnd: periodEnd ?? DateTime(2026, 7, 19),
      totalCompletedHours: 40,
      totalLateMinutes: 10,
      totalLatePayReduction: 2,
      totalBasePay: 480,
      totalBonus: 20,
      totalDeduction: 2,
      totalNetPay: 498,
      staff: const [],
    );

StaffPerformanceLoadSuccess _loaded() => StaffPerformanceLoadSuccess(
  _performance(),
  shifts: _shifts(),
  shiftDate: DateTime(2026, 7, 20),
  payroll: _payroll(),
);

void _stubRefresh(MockStaffPerformanceApiClient apiClient) {
  when(
    () => apiClient.fetchStaffPerformance(
      search: '',
      status: 'all',
      sort: 'revenue_desc',
    ),
  ).thenAnswer((_) async => _performance());
  when(
    () => apiClient.fetchStaffShifts(
      DateTime(2026, 7, 20),
      DateTime(2026, 7, 26),
    ),
  ).thenAnswer((_) async => _shifts());
  when(
    () => apiClient.fetchStaffPayroll(
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 19),
    ),
  ).thenAnswer((_) async => _payroll());
}

void main() {
  late MockStaffPerformanceApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    apiClient = MockStaffPerformanceApiClient();
  });

  group('UC32 - Manage Staff and Monitor Performance', () {
    test('ST-01: initial state should be StaffPerformanceInitial', () {
      final bloc = StaffPerformanceBloc(apiClient);
      expect(bloc.state, const StaffPerformanceInitial());
      bloc.close();
    });

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-01: should load filtered performance, weekly shifts and payroll data',
      build: () {
        when(
          () => apiClient.fetchStaffPerformance(
            search: 'alice',
            status: 'ACTIVE',
            sort: 'score_desc',
          ),
        ).thenAnswer((_) async => _performance());
        when(
          () => apiClient.fetchStaffShifts(
            DateTime(2026, 7, 20),
            DateTime(2026, 7, 26),
          ),
        ).thenAnswer((_) async => _shifts());
        when(
          () => apiClient.fetchStaffPayroll(any(), any()),
        ).thenAnswer((_) async => _payroll());
        return StaffPerformanceBloc(apiClient);
      },
      act: (bloc) => bloc.add(
        StaffPerformanceFetchRequested(
          search: 'alice',
          status: 'ACTIVE',
          sort: 'score_desc',
          shiftDate: DateTime(2026, 7, 22),
        ),
      ),
      expect: () => [
        const StaffPerformanceLoading(),
        isA<StaffPerformanceLoadSuccess>()
            .having((state) => state.search, 'search', 'alice')
            .having((state) => state.status, 'status', 'ACTIVE')
            .having((state) => state.sort, 'sort', 'score_desc')
            .having((state) => state.performance.staff.length, 'staff', 2)
            .having(
              (state) => state.shiftDate,
              'normalized Monday',
              DateTime(2026, 7, 20),
            )
            .having(
              (state) => state.shifts.single.isRecurring,
              'recurring shift',
              isTrue,
            ),
      ],
      verify: (_) {
        verify(
          () => apiClient.fetchStaffPerformance(
            search: 'alice',
            status: 'ACTIVE',
            sort: 'score_desc',
          ),
        ).called(1);
        verify(
          () => apiClient.fetchStaffShifts(
            DateTime(2026, 7, 20),
            DateTime(2026, 7, 26),
          ),
        ).called(1);
      },
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'BVA-01: selecting Sunday should request its week without emitting a duplicate state',
      build: () {
        when(
          () => apiClient.fetchStaffShifts(
            DateTime(2026, 7, 20),
            DateTime(2026, 7, 26),
          ),
        ).thenAnswer((_) async => _shifts());
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(StaffShiftDateSelected(DateTime(2026, 7, 26))),
      expect: () => <StaffPerformanceState>[],
      verify: (_) {
        verify(
          () => apiClient.fetchStaffShifts(
            DateTime(2026, 7, 20),
            DateTime(2026, 7, 26),
          ),
        ).called(1);
      },
    );

    final createRequest = const CreateBranchStaffRequestDto(
      fullName: 'Đặng An 🔥',
      email: 'new.staff@pharmacy.com',
      password: 'StrongPassword@123',
      phone: '0901234567',
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-02: should create a staff account and refresh branch staff data',
      build: () {
        when(
          () => apiClient.createStaff(createRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(BranchStaffCreateRequested(createRequest)),
      expect: () => [isA<StaffPerformanceOperationSuccess>()],
      verify: (_) {
        verify(() => apiClient.createStaff(createRequest)).called(1);
        verify(
          () => apiClient.fetchStaffPerformance(
            search: '',
            status: 'all',
            sort: 'revenue_desc',
          ),
        ).called(1);
      },
    );

    final deactivateRequest = const UpdateStaffStatusRequestDto(
      staffId: 'staff-02',
      status: 'INACTIVE',
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-03: should deactivate assigned staff and refresh the freed schedule',
      build: () {
        when(
          () => apiClient.updateStaffStatus(deactivateRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(StaffStatusUpdateRequested(deactivateRequest)),
      expect: () => [isA<StaffPerformanceOperationSuccess>()],
      verify: (_) {
        verify(() => apiClient.updateStaffStatus(deactivateRequest)).called(1);
        verify(
          () => apiClient.fetchStaffShifts(
            DateTime(2026, 7, 20),
            DateTime(2026, 7, 26),
          ),
        ).called(1);
      },
    );

    final shiftRequest = UpsertStaffShiftRequestDto(
      staffId: 'staff-01',
      shiftDate: DateTime(2026, 7, 23),
      startTime: const TimeOfDayValue(8, 0),
      endTime: const TimeOfDayValue(12, 0),
      status: 'SCHEDULED',
      notes: 'Replacement shift',
      applyToWeeklySchedule: true,
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'DT-01: should save a dated recurring shift and refresh its full week',
      build: () {
        when(
          () => apiClient.upsertShift(shiftRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(StaffShiftUpsertRequested(shiftRequest)),
      expect: () => [
        isA<StaffPerformanceOperationSuccess>().having(
          (state) => state.shiftDate,
          'week start',
          DateTime(2026, 7, 20),
        ),
      ],
      verify: (_) {
        verify(() => apiClient.upsertShift(shiftRequest)).called(1);
      },
    );

    final assessmentRequest = CreateStaffAssessmentRequestDto(
      staffId: 'staff-01',
      assessmentDate: DateTime(2026, 7, 19),
      salesTarget: 2500,
      customerRating: 4.8,
      attendancePercent: 98,
      performanceScore: 9,
      notes: 'Strong customer service',
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-04: should record an assessment and reload latest performance',
      build: () {
        when(
          () => apiClient.createAssessment(assessmentRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) =>
          bloc.add(StaffAssessmentCreateRequested(assessmentRequest)),
      expect: () => [isA<StaffPerformanceOperationSuccess>()],
      verify: (_) {
        verify(() => apiClient.createAssessment(assessmentRequest)).called(1);
        verify(
          () => apiClient.fetchStaffPerformance(
            search: '',
            status: 'all',
            sort: 'revenue_desc',
          ),
        ).called(1);
      },
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-05: should load payroll for the manager-selected period',
      build: () {
        when(
          () => apiClient.fetchStaffPayroll(
            DateTime(2026, 7, 1),
            DateTime(2026, 7, 31),
          ),
        ).thenAnswer(
          (_) async => _payroll(
            periodStart: DateTime(2026, 7, 1),
            periodEnd: DateTime(2026, 7, 31),
          ),
        );
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(
        StaffPayrollPeriodSelected(
          fromDate: DateTime(2026, 7, 1, 15),
          toDate: DateTime(2026, 7, 31, 23, 59),
        ),
      ),
      expect: () => [
        isA<StaffPerformanceLoadSuccess>()
            .having(
              (state) => state.payroll.periodStart,
              'period start',
              DateTime(2026, 7, 1),
            )
            .having(
              (state) => state.payroll.periodEnd,
              'period end',
              DateTime(2026, 7, 31),
            ),
      ],
      verify: (_) {
        verify(
          () => apiClient.fetchStaffPayroll(
            DateTime(2026, 7, 1),
            DateTime(2026, 7, 31),
          ),
        ).called(1);
      },
    );

    final payRateRequest = UpdateStaffPayRateRequestDto(
      staffId: 'staff-01',
      hourlyRate: 12,
      effectiveFrom: DateTime(2026, 7, 1),
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'HP-06: should save hourly rate and refresh payroll calculations',
      build: () {
        when(
          () => apiClient.updateStaffPayRate(payRateRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(StaffPayRateUpsertRequested(payRateRequest)),
      expect: () => [isA<StaffPerformanceOperationSuccess>()],
      verify: (_) {
        verify(() => apiClient.updateStaffPayRate(payRateRequest)).called(1);
        verify(
          () => apiClient.fetchStaffPayroll(
            DateTime(2026, 7, 1),
            DateTime(2026, 7, 19),
          ),
        ).called(1);
      },
    );

    final payrollRequest = UpsertStaffPayrollRequestDto(
      staffId: 'staff-01',
      periodStart: DateTime(2026, 7, 1),
      periodEnd: DateTime(2026, 7, 19),
      bonus: 20,
      deduction: 2,
      status: 'CONFIRMED',
      notes: 'Approved by branch manager',
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'DT-02: should confirm payroll and reload the confirmed totals',
      build: () {
        when(
          () => apiClient.upsertStaffPayroll(payrollRequest),
        ).thenAnswer((_) async {});
        _stubRefresh(apiClient);
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(StaffPayrollUpsertRequested(payrollRequest)),
      expect: () => [isA<StaffPerformanceOperationSuccess>()],
      verify: (_) {
        verify(() => apiClient.upsertStaffPayroll(payrollRequest)).called(1);
      },
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'SP-03: should keep current staff data when payroll period API fails',
      build: () {
        when(
          () => apiClient.fetchStaffPayroll(
            DateTime(2026, 7, 1),
            DateTime(2026, 7, 31),
          ),
        ).thenThrow(const BranchManagerServerException('payroll unavailable'));
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(
        StaffPayrollPeriodSelected(
          fromDate: DateTime(2026, 7, 1),
          toDate: DateTime(2026, 7, 31),
        ),
      ),
      expect: () => [
        isA<StaffPerformanceOperationFailure>()
            .having((state) => state.message, 'message', 'payroll unavailable')
            .having((state) => state.performance.staff.length, 'staff', 2),
      ],
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'SP-01: should retain current data and expose a known operation error',
      build: () {
        when(
          () => apiClient.createStaff(createRequest),
        ).thenThrow(const BranchManagerServerException('email already exists'));
        return StaffPerformanceBloc(apiClient);
      },
      seed: _loaded,
      act: (bloc) => bloc.add(BranchStaffCreateRequested(createRequest)),
      expect: () => [
        isA<StaffPerformanceOperationFailure>()
            .having((state) => state.message, 'message', 'email already exists')
            .having(
              (state) => state.performance.staff.length,
              'preserved staff',
              2,
            )
            .having((state) => state.shifts.length, 'preserved shifts', 1),
      ],
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'SP-02: should emit load failure when initial staff request is unauthorized',
      build: () {
        when(
          () => apiClient.fetchStaffPerformance(
            search: null,
            status: 'all',
            sort: 'revenue_desc',
          ),
        ).thenThrow(const BranchManagerUnauthorizedException());
        return StaffPerformanceBloc(apiClient);
      },
      act: (bloc) => bloc.add(const StaffPerformanceFetchRequested()),
      expect: () => [
        const StaffPerformanceLoading(),
        isA<StaffPerformanceLoadFailure>(),
      ],
      verify: (_) {
        verifyNever(() => apiClient.fetchStaffShifts(any(), any()));
        verifyNever(() => apiClient.fetchStaffPayroll(any(), any()));
      },
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'EG-01: should emit generic failure for malformed staff response',
      build: () {
        when(
          () => apiClient.fetchStaffPerformance(
            search: null,
            status: 'all',
            sort: 'revenue_desc',
          ),
        ).thenThrow(const FormatException('bad staff payload'));
        return StaffPerformanceBloc(apiClient);
      },
      act: (bloc) => bloc.add(const StaffPerformanceFetchRequested()),
      expect: () => [
        const StaffPerformanceLoading(),
        isA<StaffPerformanceLoadFailure>(),
      ],
    );

    blocTest<StaffPerformanceBloc, StaffPerformanceState>(
      'ST-I1: create, status, shift and assessment events should be ignored before load',
      build: () => StaffPerformanceBloc(apiClient),
      act: (bloc) {
        bloc
          ..add(BranchStaffCreateRequested(createRequest))
          ..add(StaffStatusUpdateRequested(deactivateRequest))
          ..add(StaffShiftUpsertRequested(shiftRequest))
          ..add(StaffAssessmentCreateRequested(assessmentRequest));
      },
      expect: () => <StaffPerformanceState>[],
      verify: (_) {
        verifyNever(() => apiClient.createStaff(createRequest));
        verifyNever(() => apiClient.updateStaffStatus(deactivateRequest));
        verifyNever(() => apiClient.upsertShift(shiftRequest));
        verifyNever(() => apiClient.createAssessment(assessmentRequest));
      },
    );
  });
}
