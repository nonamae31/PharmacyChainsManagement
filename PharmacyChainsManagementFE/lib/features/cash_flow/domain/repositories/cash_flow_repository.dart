import '../entities/cash_flow_statistics_entity.dart';
import '../entities/branch_entity.dart';

abstract class CashFlowRepository {
  Future<CashFlowStatisticsEntity> getCashFlow(String startDate, String endDate, {String? branchId});
  Future<List<BranchEntity>> getBranches();
}
