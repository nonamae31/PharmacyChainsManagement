import '../../../core/network/branch_manager_api_client_base.dart';
import '../entity/staff_performance_dto.dart';

class StaffPerformanceApiClient {
  final BranchManagerApiClientBase _apiClient;

  StaffPerformanceApiClient(this._apiClient);

  Future<StaffPerformanceDto> fetchStaffPerformance({String? search}) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/staff-performance',
      queryParameters: {if (search != null && search.isNotEmpty) 'search': search},
    );
    return StaffPerformanceDto.fromJson(response.data as Map<String, dynamic>);
  }
}
