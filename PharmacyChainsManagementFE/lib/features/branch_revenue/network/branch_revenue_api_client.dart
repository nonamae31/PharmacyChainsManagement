import 'package:dio/dio.dart';

import '../../../core/network/branch_manager_api_client_base.dart';
import '../entity/branch_revenue_dto.dart';

class BranchRevenueApiClient {
  final BranchManagerApiClientBase _apiClient;

  BranchRevenueApiClient(this._apiClient);

  Future<BranchRevenueDto> fetchRevenue({
    required String period,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/revenue',
      queryParameters: {
        'period': period,
        if (fromDate != null) 'fromDate': _formatDate(fromDate),
        if (toDate != null) 'toDate': _formatDate(toDate),
      },
    );
    return BranchRevenueDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<int>> exportRevenue({required String period, DateTime? fromDate, DateTime? toDate}) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/revenue/export.csv',
      queryParameters: {
        'period': period,
        if (fromDate != null) 'fromDate': _formatDate(fromDate),
        if (toDate != null) 'toDate': _formatDate(toDate),
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return List<int>.from(response.data as List<dynamic>);
  }

  String _formatDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
