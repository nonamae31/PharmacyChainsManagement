import 'dart:convert';
import '../../../../core/network/api_client.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/business_admin_request_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/business_admin_entity.dart';
import '../../domain/repositories/business_admin_repository.dart';
import '../models/business_admin_model.dart';

class BusinessAdminRepositoryImpl implements BusinessAdminRepository {
  static const String _cacheKey = 'BUSINESS_ADMINS_CACHE';

  BusinessAdminRepositoryImpl();

  @override
  Future<List<BusinessAdminEntity>> getBusinessAdmins({bool forceRefresh = false}) async {
    const storage = FlutterSecureStorage();

    if (!forceRefresh) {
      final cachedData = await storage.read(key: _cacheKey);
      if (cachedData != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedData);
          return jsonList.map((json) => BusinessAdminModel.fromJson(json)).toList();
        } catch (e) {
          // Fall through to fetch from API
        }
      }
    }

    try {
      final dio = ApiClient.createDio();
      final response = await dio.get('/api/v1/business-admin');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final models = data.map((json) => BusinessAdminModel.fromJson(json)).toList();
        
        // Cache the new data
        await storage.write(key: _cacheKey, value: jsonEncode(models.map((m) => m.toJson()).toList()));
        return models;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi khi tải danh sách Admin');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối tới server: $e');
    }
  }

  @override
  Future<void> createBusinessAdmin(BusinessAdminRequestModel request) async {
    try {
      final dio = ApiClient.createDio();
      final response = await dio.post('/api/v1/business-admin', data: {
        'fullName': request.fullName,
        'email': request.email,
        'phone': request.phone,
      });

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Tạo Business Admin thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hoặc xử lý từ server: $e');
    }
  }

  @override
  Future<Either<Failure, void>> deactivateBusinessAdmin(String id, String reason) async {
    try {
      final dio = ApiClient.createDio();
      final response = await dio.post('/api/v1/business-admin/deactivate', data: {
        'id': id,
        'reason': reason,
      });

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Vô hiệu hóa thất bại.'));
      }
    } catch (e) {
      return Left(ServerFailure('Lỗi kết nối hoặc xử lý từ server: $e'));
    }
  }
}
