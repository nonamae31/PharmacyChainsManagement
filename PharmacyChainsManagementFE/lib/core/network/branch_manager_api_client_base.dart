import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/branch_manager_app_strings.dart';
import '../../features/auth/network/secure_storage_service.dart';
import 'branch_manager_network_exceptions.dart';

final class BranchManagerApiClientBase {
  late final Dio _dio;

  BranchManagerApiClientBase() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:7000',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Response<dynamic>> post(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  BranchManagerAppException _mapException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const BranchManagerTimeoutException();
    }
    if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
      return const BranchManagerUnauthorizedException();
    }
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['detail'] ?? responseData['title'];
      if (message != null) {
        return BranchManagerServerException(message.toString());
      }
    }
    return const BranchManagerServerException(AppStrings.dataCannotLoad);
  }
}
