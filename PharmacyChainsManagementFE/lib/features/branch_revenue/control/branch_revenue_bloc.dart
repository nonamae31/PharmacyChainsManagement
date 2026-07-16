import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/branch_manager_app_strings.dart';
import '../../../core/network/branch_manager_network_exceptions.dart';
import '../network/branch_revenue_api_client.dart';
import 'branch_revenue_event.dart';
import 'branch_revenue_state.dart';

class BranchRevenueBloc extends Bloc<BranchRevenueEvent, BranchRevenueState> {
  final BranchRevenueApiClient _apiClient;

  BranchRevenueBloc(this._apiClient) : super(const BranchRevenueInitial()) {
    on<BranchRevenueFetchRequested>(_onFetchRequested);
    on<BranchRevenueSearchChanged>(_onSearchChanged);
    on<BranchRevenueExportRequested>(_onExportRequested);
  }

  Future<void> _onFetchRequested(BranchRevenueFetchRequested event, Emitter<BranchRevenueState> emit) async {
    emit(const BranchRevenueLoading());
    try {
      final revenue = await _apiClient.fetchRevenue(period: event.period, fromDate: event.fromDate, toDate: event.toDate);
      emit(BranchRevenueLoadSuccess(
        revenue: revenue,
        period: event.period,
        visiblePerformance: revenue.performanceByTime,
      ));
    } on BranchManagerAppException catch (error) {
      emit(BranchRevenueLoadFailure(error.message));
    } catch (_) {
      emit(const BranchRevenueLoadFailure(AppStrings.dataCannotLoad));
    }
  }

  void _onSearchChanged(BranchRevenueSearchChanged event, Emitter<BranchRevenueState> emit) {
    final current = state;
    if (current is! BranchRevenueLoadSuccess) return;
    final query = event.query.trim().toLowerCase();
    emit(BranchRevenueLoadSuccess(
      revenue: current.revenue,
      period: current.period,
      searchQuery: event.query,
      visiblePerformance: current.revenue.performanceByTime
          .where((item) => item.timeBlock.toLowerCase().contains(query) || item.status.toLowerCase().contains(query))
          .toList(growable: false),
    ));
  }

  Future<void> _onExportRequested(BranchRevenueExportRequested event, Emitter<BranchRevenueState> emit) async {
    final current = state;
    if (current is! BranchRevenueLoadSuccess) return;
    try {
      final bytes = await _apiClient.exportRevenue(
        period: current.period,
        fromDate: current.period == 'custom' ? current.revenue.fromDate : null,
        toDate: current.period == 'custom' ? current.revenue.toDate : null,
      );
      emit(BranchRevenueExportSuccess(
        revenue: current.revenue,
        period: current.period,
        searchQuery: current.searchQuery,
        visiblePerformance: current.visiblePerformance,
        bytes: bytes,
      ));
    } on BranchManagerAppException catch (error) {
      emit(BranchRevenueLoadFailure(error.message));
    } catch (_) {
      emit(const BranchRevenueLoadFailure(AppStrings.dataCannotLoad));
    }
  }
}
