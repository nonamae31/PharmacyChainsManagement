import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/domain/usecases/get_cash_flow_usecase.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/domain/usecases/get_branches.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/presentation/bloc/cash_flow_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/presentation/bloc/cash_flow_event.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/presentation/bloc/cash_flow_state.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/domain/entities/cash_flow_statistics_entity.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/domain/entities/branch_entity.dart';

class MockGetCashFlowUseCase extends Mock implements GetCashFlowUseCase {}
class MockGetBranches extends Mock implements GetBranches {}

void main() {
  late MockGetCashFlowUseCase mockGetCashFlowUseCase;
  late MockGetBranches mockGetBranches;
  late CashFlowBloc sut;

  final tCashFlow = CashFlowStatisticsEntity(
    totalInflow: 1000,
    totalOutflow: 500,
    netCashFlow: 500,
    dailyData: const [],
    recentTransactions: const [],
    liquidityForecasts: const [],
    budgetAllocations: const [],
  );
  
  final List<BranchEntity> tBranches = [BranchEntity(id: 'b1', name: 'Branch 1')];

  setUp(() {
    mockGetCashFlowUseCase = MockGetCashFlowUseCase();
    mockGetBranches = MockGetBranches();
    sut = CashFlowBloc(
      getCashFlowUseCase: mockGetCashFlowUseCase,
      getBranches: mockGetBranches,
    );
  });

  tearDown(() {
    sut.close();
  });

  group('CashFlowBloc', () {
    test('initial state is CashFlowInitial', () {
      expect(sut.state, CashFlowInitial());
    });

    // ═══════════════════════════════════════════════════
    // HAPPY PATH
    // ═══════════════════════════════════════════════════
    blocTest<CashFlowBloc, CashFlowState>(
      'HP-01: should emit [Loading, Loaded] when use cases succeed',
      build: () {
        when(() => mockGetCashFlowUseCase(any(), any(), branchId: any(named: 'branchId')))
            .thenAnswer((_) async => tCashFlow);
        when(() => mockGetBranches.execute())
            .thenAnswer((_) async => tBranches);
        return sut;
      },
      act: (bloc) => bloc.add(const FetchCashFlowEvent(startDate: '2023-01-01', endDate: '2023-01-31')),
      expect: () => [
        CashFlowLoading(),
        CashFlowLoaded(cashFlow: tCashFlow, branches: tBranches),
      ],
      verify: (_) {
        verify(() => mockGetCashFlowUseCase('2023-01-01', '2023-01-31', branchId: null)).called(1);
        verify(() => mockGetBranches.execute()).called(1);
      },
    );

    // ═══════════════════════════════════════════════════
    // SAD PATH
    // ═══════════════════════════════════════════════════
    blocTest<CashFlowBloc, CashFlowState>(
      'SP-01: should emit [Loading, Error] when GetCashFlowUseCase fails',
      build: () {
        when(() => mockGetCashFlowUseCase(any(), any(), branchId: any(named: 'branchId')))
            .thenThrow(Exception('Server error'));
        return sut;
      },
      act: (bloc) => bloc.add(const FetchCashFlowEvent(startDate: '2023-01-01', endDate: '2023-01-31')),
      expect: () => [
        CashFlowLoading(),
        const CashFlowError(message: 'Exception: Server error'),
      ],
    );

    // ═══════════════════════════════════════════════════
    // BOUNDARY VALUE ANALYSIS & ERROR GUESSING
    // ═══════════════════════════════════════════════════
    blocTest<CashFlowBloc, CashFlowState>(
      'EP/BVA: should emit Error immediately if startDate > endDate without calling usecases',
      build: () {
        return sut;
      },
      act: (bloc) => bloc.add(const FetchCashFlowEvent(startDate: '2023-12-31', endDate: '2023-01-01')),
      expect: () => [
        const CashFlowError(message: 'Start date cannot be after end date'),
      ],
      verify: (_) {
        verifyNever(() => mockGetCashFlowUseCase(any(), any(), branchId: any(named: 'branchId')));
        verifyNever(() => mockGetBranches.execute());
      },
    );
  });
}
