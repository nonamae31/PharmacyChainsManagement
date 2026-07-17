import '../../../core/network/branch_manager_api_client_base.dart';
import '../entity/staff_performance_dto.dart';
import '../entity/staff_management_dto.dart';

class StaffPerformanceApiClient {
  final BranchManagerApiClientBase _apiClient;

  StaffPerformanceApiClient(this._apiClient);

  Future<StaffPerformanceDto> fetchStaffPerformance({
    String? search,
    String? status,
    String sort = 'revenue_desc',
  }) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/staff-performance',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status != 'all') 'status': status,
        'sort': sort,
      },
    );
    return StaffPerformanceDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createStaff(CreateBranchStaffRequestDto request) async {
    await _apiClient.post(
      '/api/v1/branch-manager/staff',
      data: request.toJson(),
    );
  }

  Future<void> upsertShift(UpsertStaffShiftRequestDto request) async {
    await _apiClient.post(
      '/api/v1/branch-manager/staff-shifts',
      data: request.toJson(),
    );
  }

  Future<void> createAssessment(CreateStaffAssessmentRequestDto request) async {
    await _apiClient.post(
      '/api/v1/branch-manager/staff-assessments',
      data: request.toJson(),
    );
  }
}
