import 'package:dio/dio.dart';
import '../../../core/network/network_exceptions.dart';
import '../entity/inventory_valuation_response_dto.dart';
import '../entity/receive_goods_request_dto.dart';
import '../entity/issue_stock_request_dto.dart';
import '../entity/stocktake_request_dto.dart';
import '../entity/batch_traceability_response_dto.dart';

class InventoryApiClient {
  final Dio _dio;

  InventoryApiClient(this._dio);

  Future<InventoryValuationResponseDto> getInventoryValuation(String branchId) async {
    // MOCK DATA FOR TESTING UI WITHOUT BACKEND
    await Future.delayed(const Duration(seconds: 1));
    return const InventoryValuationResponseDto(
      totalValue: 1520450000.0,
      items: [
        InventoryValuationItemDto(
          medicineId: 'MED-001',
          medicineName: 'Panadol Extra',
          totalAvailableQuantity: 1500,
          averageCost: 50000.0,
          totalValue: 75000000.0,
        ),
        InventoryValuationItemDto(
          medicineId: 'MED-002',
          medicineName: 'Amoxicillin 500mg',
          totalAvailableQuantity: 500,
          averageCost: 20000.0,
          totalValue: 10000000.0,
        ),
        InventoryValuationItemDto(
          medicineId: 'MED-003',
          medicineName: 'Vitamin C Sủi',
          totalAvailableQuantity: 8,
          averageCost: 35000.0,
          totalValue: 280000.0,
        ),
        InventoryValuationItemDto(
          medicineId: 'MED-004',
          medicineName: 'Khẩu trang y tế 4 lớp',
          totalAvailableQuantity: 3,
          averageCost: 45000.0,
          totalValue: 135000.0,
        ),
      ],
    );
  }

  Future<void> receiveGoods(ReceiveGoodsRequestDto request) async {
    try {
      await _dio.post(
        '/api/v1/inventory/receive-goods',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<void> issueStock(IssueStockRequestDto request) async {
    try {
      await _dio.post(
        '/api/v1/inventory/issue-stock',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<void> submitStocktake(StocktakeRequestDto request) async {
    try {
      await _dio.post(
        '/api/v1/inventory/stocktake',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<BatchTraceabilityResponseDto> getBatchTraceability(String batchId) async {
    try {
      final response = await _dio.get('/api/v1/inventory/batches/$batchId/trace');
      
      if (response.data != null && response.data['data'] != null) {
        return BatchTraceabilityResponseDto.fromJson(response.data['data']);
      }
      
      throw const ServerException('Invalid response format');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.sendTimeout) {
      throw const NetworkTimeoutException();
    }
    
    if (e.response?.statusCode == 401) {
      throw const UnauthorizedException();
    }
    
    final message = e.response?.data?['message'] ?? e.message ?? 'Unknown server error';
    throw ServerException(message);
  }
}
