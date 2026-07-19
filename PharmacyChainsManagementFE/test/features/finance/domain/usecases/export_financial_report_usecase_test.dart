import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/finance/data/models/export_criteria_model.dart';
import 'package:pharmacy_chains_management_fe/features/finance/domain/repositories/financial_repository.dart';
import 'package:pharmacy_chains_management_fe/features/finance/domain/usecases/export_financial_report_usecase.dart';

class MockFinancialRepository extends Mock implements FinancialRepository {}

void main() {
  late ExportFinancialReportUseCase usecase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    usecase = ExportFinancialReportUseCase(mockRepository);
  });

  group('ExportFinancialReportUseCase', () {
    final tStartDate = DateTime.utc(2023, 1, 1);
    final tEndDate = DateTime.utc(2023, 1, 31);
    final tCriteria = ExportCriteriaModel(
      branchId: 'B001',
      startDate: tStartDate,
      endDate: tEndDate,
      format: 'PDF',
    );
    final tBytes = Uint8List.fromList([1, 2, 3]);

    test('should get Uint8List from the repository when successful', () async {
      // Arrange
      when(() => mockRepository.exportFinancialReport(any()))
          .thenAnswer((_) async => Right(tBytes));

      // Act
      final result = await usecase(tCriteria);

      // Assert
      expect(result, Right(tBytes));
      verify(() => mockRepository.exportFinancialReport(tCriteria)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure from the repository when unsuccessful', () async {
      // Arrange
      const tFailure = ServerFailure('Server Error');
      when(() => mockRepository.exportFinancialReport(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tCriteria);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.exportFinancialReport(tCriteria)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
