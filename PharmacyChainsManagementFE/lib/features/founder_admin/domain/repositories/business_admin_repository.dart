import '../entities/business_admin_entity.dart';

abstract class BusinessAdminRepository {
  Future<List<BusinessAdminEntity>> getBusinessAdmins({bool forceRefresh = false});
}
