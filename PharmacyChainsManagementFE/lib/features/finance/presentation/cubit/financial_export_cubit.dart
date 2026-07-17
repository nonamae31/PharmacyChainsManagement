import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/export_financial_report_usecase.dart';
import '../../data/models/export_criteria_model.dart';
import 'financial_export_state.dart';

class FinancialExportCubit extends Cubit<FinancialExportState> {
  final ExportFinancialReportUseCase exportFinancialReportUseCase;

  FinancialExportCubit({required this.exportFinancialReportUseCase})
      : super(const FinancialExportInitial());

  Future<void> exportReport(ExportCriteriaModel criteria) async {
    emit(const FinancialExportLoading());
    final result = await exportFinancialReportUseCase(criteria);
    result.fold(
      (failure) => emit(FinancialExportError(failure.message)),
      (fileBytes) => emit(FinancialExportSuccess(fileBytes)),
    );
  }
}
