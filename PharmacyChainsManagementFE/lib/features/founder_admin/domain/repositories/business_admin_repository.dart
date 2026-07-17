import '../entities/business_admin_entity.dart';
import '../../data/models/business_admin_request_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class BusinessAdminRepository {
  Future<List<BusinessAdminEntity>> getBusinessAdmins({bool forceRefresh = false});
  Future<void> createBusinessAdmin(BusinessAdminRequestModel request);
  Future<Either<Failure, void>> updateBusinessAdmin(String id, BusinessAdminRequestModel request);
  Future<Either<Failure, void>> deactivateBusinessAdmin(String id, String reason);
  Future<Either<Failure, void>> softDeleteBusinessAdmin(String id);
  Future<Either<Failure, void>> reactivateBusinessAdmin(String id);
}
