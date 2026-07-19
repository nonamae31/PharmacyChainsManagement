import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_revenue_report.dart';
import '../../domain/entities/revenue_report_request.dart';
import 'revenue_report_event.dart';
import 'revenue_report_state.dart';
import '../../../../core/app_logger.dart';
import '../../domain/entities/revenue_report_response.dart';

class RevenueReportBloc extends Bloc<RevenueReportEvent, RevenueReportState> {
  final GenerateRevenueReportUseCase generateRevenueReportUseCase;

  RevenueReportBloc({required this.generateRevenueReportUseCase}) : super(RevenueReportInitial()) {
    on<FetchRevenueReportEvent>(_onFetchRevenueReport);
  }

  Future<void> _onFetchRevenueReport(FetchRevenueReportEvent event, Emitter<RevenueReportState> emit) async {
    emit(RevenueReportLoading());
    try {
      final result = await generateRevenueReportUseCase(
        RevenueReportRequest(
          fromDate: event.startDate, 
          toDate: event.endDate,
          branchId: '00000000-0000-0000-0000-000000000000', // Default branch
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to fetch revenue report: ${failure.message}');
          emit(RevenueReportError(failure.message));
        },
        (report) {
          emit(RevenueReportLoaded(report));
        },
      );
    } catch (e) {
      AppLogger.error('Exception fetching revenue report', e);
      emit(const RevenueReportError('An unexpected error occurred.'));
    }
  }
}
