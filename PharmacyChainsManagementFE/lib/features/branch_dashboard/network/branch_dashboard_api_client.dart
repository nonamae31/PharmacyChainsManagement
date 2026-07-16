import '../../../core/network/branch_manager_api_client_base.dart';
import '../entity/branch_dashboard_dto.dart';
import '../entity/daily_revenue_confirmation_dto.dart';

class BranchDashboardApiClient {
  final BranchManagerApiClientBase _apiClient;

  BranchDashboardApiClient(this._apiClient);

  Future<BranchDashboardDto> fetchDashboard() async {
    final response = await _apiClient.get('/api/v1/branch-manager/dashboard');
    return BranchDashboardDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DailyRevenueConfirmationDto> confirmDailyRevenue(ConfirmDailyRevenueRequestDto request) async {
    final response = await _apiClient.post('/api/v1/branch-manager/daily-revenue/confirm', data: request.toJson());
    return DailyRevenueConfirmationDto.fromJson(response.data as Map<String, dynamic>);
  }
}
