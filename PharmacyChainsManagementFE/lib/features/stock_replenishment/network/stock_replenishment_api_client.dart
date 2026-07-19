import 'package:dio/dio.dart';

import '../../../core/network/network_exceptions.dart';
import '../entity/stock_replenishment_dto.dart';

class StockReplenishmentApiClient {
  final Dio _dio;

  StockReplenishmentApiClient(this._dio);

  Future<List<StockReplenishmentOptionDto>> fetchBranchOptions() async {
    try {
      final response = await _dio.get(
        '/api/v1/branch-manager/inventory/replenishment-options',
      );
      return (response.data as List<dynamic>)
          .map(
            (item) => StockReplenishmentOptionDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<List<StockReplenishmentRequestDto>> fetchBranchRequests() async {
    try {
      final response = await _dio.get(
        '/api/v1/branch-manager/inventory/replenishment-requests',
      );
      return _parseRequests(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<StockReplenishmentRequestDto> createBranchRequest(
    CreateStockReplenishmentRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/branch-manager/inventory/replenishment-requests',
        data: request.toJson(),
      );
      return StockReplenishmentRequestDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<List<StockReplenishmentRequestDto>> fetchInventoryQueue({
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/inventory/replenishment-requests',
        queryParameters: {
          if (status != null && status != 'ALL') 'status': status,
        },
      );
      return _parseRequests(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<StockReplenishmentRequestDto> updateInventoryStatus(
    String requestId,
    UpdateStockReplenishmentStatusDto request,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/inventory/replenishment-requests/$requestId/status',
        data: request.toJson(),
      );
      return StockReplenishmentRequestDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<List<StockReplenishmentSourceDto>> fetchDispatchSources(
    String requestId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/inventory/replenishment-requests/$requestId/dispatch-sources',
      );
      return (response.data as List<dynamic>)
          .map(
            (item) => StockReplenishmentSourceDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<StockReplenishmentRequestDto> dispatchInventoryRequest(
    String requestId,
    DispatchStockReplenishmentDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/inventory/replenishment-requests/$requestId/dispatch',
        data: request.toJson(),
      );
      return StockReplenishmentRequestDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  List<StockReplenishmentRequestDto> _parseRequests(dynamic data) {
    return (data as List<dynamic>)
        .map(
          (item) => StockReplenishmentRequestDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }

  AppException _mapException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkTimeoutException();
    }
    if (error.response?.statusCode == 401 ||
        error.response?.statusCode == 403) {
      return const UnauthorizedException();
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['title'];
      if (message != null) return ServerException(message.toString());
    }
    return const ServerException(
      'Replenishment request data cannot be loaded. Please try again.',
    );
  }
}
