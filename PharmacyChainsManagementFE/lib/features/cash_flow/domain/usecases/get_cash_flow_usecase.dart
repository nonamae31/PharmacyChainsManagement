import '../entities/cash_flow_statistics_entity.dart';
import '../repositories/cash_flow_repository.dart';

class GetCashFlowUseCase {
  final CashFlowRepository repository;

  GetCashFlowUseCase(this.repository);

  Future<CashFlowStatisticsEntity> call(String startDate, String endDate, {String? branchId}) {
    return repository.getCashFlow(startDate, endDate, branchId: branchId);
  }
}
