import 'package:flutter_test/flutter_test.dart';
import 'package:PharmacyChainsManagementFE/features/finance/data/models/export_criteria_model.dart';

void main() {
  group('ExportCriteriaModel', () {
    final tStartDate = DateTime.utc(2023, 1, 1);
    final tEndDate = DateTime.utc(2023, 1, 31);
    final tExportCriteriaModel = ExportCriteriaModel(
      branchId: 'B001',
      startDate: tStartDate,
      endDate: tEndDate,
      format: 'PDF',
    );

    group('fromJson', () {
      test('should create model from valid JSON', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'branchId': 'B001',
          'startDate': tStartDate.toIso8601String(),
          'endDate': tEndDate.toIso8601String(),
          'format': 'PDF',
        };
        // Act
        final result = ExportCriteriaModel.fromJson(jsonMap);
        // Assert
        expect(result, tExportCriteriaModel);
      });

      test('should throw error when missing required fields', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'branchId': 'B001',
          'format': 'PDF',
        };
        // Act & Assert
        expect(() => ExportCriteriaModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
      });
      
      test('should handle empty JSON map', () {
        expect(() => ExportCriteriaModel.fromJson({}), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = tExportCriteriaModel.toJson();
        // Assert
        final expectedMap = {
          'branchId': 'B001',
          'startDate': tStartDate.toUtc().toIso8601String(),
          'endDate': tEndDate.toUtc().toIso8601String(),
          'format': 'PDF',
        };
        expect(result, expectedMap);
      });
      
      test('should uppercase the format string in JSON', () {
        final lowerCaseModel = ExportCriteriaModel(
          branchId: 'B001',
          startDate: tStartDate,
          endDate: tEndDate,
          format: 'csv',
        );
        final result = lowerCaseModel.toJson();
        expect(result['format'], 'CSV');
      });
    });

    group('equality', () {
      test('should consider instances equal when properties match', () {
        final a = ExportCriteriaModel(
          branchId: 'B001',
          startDate: tStartDate,
          endDate: tEndDate,
          format: 'PDF',
        );
        final b = ExportCriteriaModel(
          branchId: 'B001',
          startDate: tStartDate,
          endDate: tEndDate,
          format: 'PDF',
        );
        expect(a, equals(b));
      });

      test('should consider instances not equal when properties differ', () {
        final a = ExportCriteriaModel(
          branchId: 'B001',
          startDate: tStartDate,
          endDate: tEndDate,
          format: 'PDF',
        );
        final b = ExportCriteriaModel(
          branchId: 'B002',
          startDate: tStartDate,
          endDate: tEndDate,
          format: 'PDF',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
