import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/export_criteria_model.dart';

abstract class FinancialRepository {
  Future<Either<Failure, Uint8List>> exportFinancialReport(ExportCriteriaModel criteria);
}
