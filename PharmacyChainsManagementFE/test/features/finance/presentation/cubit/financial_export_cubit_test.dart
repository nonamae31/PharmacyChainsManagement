import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/finance/data/models/export_criteria_model.dart';
import 'package:pharmacy_chains_management_fe/features/finance/domain/usecases/export_financial_report_usecase.dart';
import 'package:pharmacy_chains_management_fe/features/finance/presentation/cubit/financial_export_cubit.dart';
import 'package:pharmacy_chains_management_fe/features/finance/presentation/cubit/financial_export_state.dart';

class MockExportFinancialReportUseCase extends Mock implements ExportFinancialReportUseCase {}

class FakeExportCriteriaModel extends Fake implements ExportCriteriaModel {}

void main() {
  late FinancialExportCubit cubit;
  late MockExportFinancialReportUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(FakeExportCriteriaModel());
  });

  setUp(() {
    mockUseCase = MockExportFinancialReportUseCase();
    cubit = FinancialExportCubit(exportFinancialReportUseCase: mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('FinancialExportCubit', () {
    final tStartDate = DateTime.utc(2023, 1, 1);
    final tEndDate = DateTime.utc(2023, 1, 31);
    final tCriteria = ExportCriteriaModel(
      branchId: 'B001',
      startDate: tStartDate,
      endDate: tEndDate,
      format: 'PDF',
    );
    final tBytes = Uint8List.fromList([1, 2, 3]);
    const tErrorMessage = 'Server Error';

    test('initial state should be FinancialExportInitial', () {
      expect(cubit.state, const FinancialExportInitial());
    });

    blocTest<FinancialExportCubit, FinancialExportState>(
      'should emit [FinancialExportLoading, FinancialExportSuccess] when export is successful',
      build: () {
        when(() => mockUseCase.call(any()))
            .thenAnswer((_) async => Right(tBytes));
        return cubit;
      },
      act: (cubit) => cubit.exportReport(tCriteria),
      expect: () => [
        const FinancialExportLoading(),
        FinancialExportSuccess(tBytes),
      ],
      verify: (_) {
        verify(() => mockUseCase.call(tCriteria)).called(1);
      },
    );

    blocTest<FinancialExportCubit, FinancialExportState>(
      'should emit [FinancialExportLoading, FinancialExportError] when export fails',
      build: () {
        when(() => mockUseCase.call(any()))
            .thenAnswer((_) async => const Left(ServerFailure(tErrorMessage)));
        return cubit;
      },
      act: (cubit) => cubit.exportReport(tCriteria),
      expect: () => [
        const FinancialExportLoading(),
        const FinancialExportError(tErrorMessage),
      ],
      verify: (_) {
        verify(() => mockUseCase.call(tCriteria)).called(1);
      },
    );
  });
}
