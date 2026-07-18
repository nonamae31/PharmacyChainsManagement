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

  Future<List<StaffShiftDto>> fetchStaffShifts(DateTime date) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/staff-shifts',
      queryParameters: {'date': _date(date)},
    );
    return (response.data as List<dynamic>)
        .map((json) => StaffShiftDto.fromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> createAssessment(CreateStaffAssessmentRequestDto request) async {
    await _apiClient.post(
      '/api/v1/branch-manager/staff-assessments',
      data: request.toJson(),
    );
  }

  Future<void> updateStaffStatus(UpdateStaffStatusRequestDto request) async {
    await _apiClient.patch(
      '/api/v1/branch-manager/staff/${request.staffId}/status',
      data: request.toJson(),
    );
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
