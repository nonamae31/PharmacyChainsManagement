import '../entities/branch_entity.dart';
import '../repositories/cash_flow_repository.dart';

class GetBranches {
  final CashFlowRepository repository;

  GetBranches(this.repository);

  Future<List<BranchEntity>> execute() {
    return repository.getBranches();
  }
}
