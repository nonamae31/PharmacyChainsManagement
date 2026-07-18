import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/export_criteria_model.dart';
import '../repositories/financial_repository.dart';

class ExportFinancialReportUseCase {
  final FinancialRepository repository;

  const ExportFinancialReportUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call(ExportCriteriaModel params) {
    return repository.exportFinancialReport(params);
  }
}
