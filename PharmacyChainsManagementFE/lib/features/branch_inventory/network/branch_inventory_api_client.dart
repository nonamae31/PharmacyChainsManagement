import 'package:dio/dio.dart';

import '../../../core/network/branch_manager_api_client_base.dart';
import '../entity/branch_inventory_dto.dart';
import '../entity/shipment_dto.dart';

class BranchInventoryApiClient {
  final BranchManagerApiClientBase _apiClient;

  BranchInventoryApiClient(this._apiClient);

  Future<BranchInventoryDto> fetchInventory({
    String? search,
    String? category,
    String? status,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/inventory',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
      },
    );
    return BranchInventoryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<int>> exportInventory() async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/inventory/export.csv',
      options: Options(responseType: ResponseType.bytes),
    );
    return List<int>.from(response.data as List<dynamic>);
  }

  Future<ShipmentOptionsDto> fetchShipmentOptions() async {
    final response = await _apiClient.get(
      '/api/v1/branch-manager/inventory/shipment-options',
    );
    return ShipmentOptionsDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createShipment(CreateShipmentRequestDto request) async {
    await _apiClient.post(
      '/api/v1/branch-manager/inventory/shipments',
      data: request.toJson(),
    );
  }
}
