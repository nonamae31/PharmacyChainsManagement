import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/business_admin_repository.dart';

class DeactivateBusinessAdminUseCase {
  final BusinessAdminRepository repository;

  DeactivateBusinessAdminUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String reason) async {
    return await repository.deactivateBusinessAdmin(id, reason);
  }
}
