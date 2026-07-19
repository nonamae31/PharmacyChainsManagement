import 'package:flutter_bloc/flutter_bloc.dart';
import 'cash_flow_event.dart';
import 'cash_flow_state.dart';
import '../../domain/usecases/get_cash_flow_usecase.dart';
import '../../domain/usecases/get_branches.dart';

class CashFlowBloc extends Bloc<CashFlowEvent, CashFlowState> {
  final GetCashFlowUseCase getCashFlowUseCase;
  final GetBranches getBranches;

  CashFlowBloc({required this.getCashFlowUseCase, required this.getBranches}) : super(CashFlowInitial()) {
    on<FetchCashFlowEvent>(_onFetchCashFlowEvent);
  }

  Future<void> _onFetchCashFlowEvent(FetchCashFlowEvent event, Emitter<CashFlowState> emit) async {
    // Validate startDate and endDate
    final start = DateTime.tryParse(event.startDate);
    final end = DateTime.tryParse(event.endDate);

    if (start != null && end != null && start.isAfter(end)) {
      emit(const CashFlowError(message: 'Start date cannot be after end date'));
      return;
    }

    emit(CashFlowLoading());
    try {
      final cashFlow = await getCashFlowUseCase(
        event.startDate,
        event.endDate,
        branchId: event.branchId,
      );
      final branches = await getBranches.execute();
      emit(CashFlowLoaded(cashFlow: cashFlow, branches: branches));
    } catch (e) {
      emit(CashFlowError(message: e.toString()));
    }
  }
}
