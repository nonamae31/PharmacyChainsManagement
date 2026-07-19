import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/network_exceptions.dart';
import '../../auth/network/secure_storage_service.dart';
import '../entity/branch_dto.dart';
import '../entity/business_analysis_report_dto.dart';
import '../entity/forgot_password_dto.dart';
import '../entity/medicine_statistics_dto.dart';
import '../entity/profile_dto.dart';

class BusinessAdminApiClient {
  final Dio _dio;

  BusinessAdminApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:7000',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<ProfileDto> fetchProfile() async {
    final response = await _request(() => _dio.get('/api/v1/profile'));
    return ProfileDto.fromJson(_payload(response.data));
  }

  Future<ProfileDto> updateProfile(UpdateProfileRequestDto request) async {
    final response = await _request(
      () => _dio.put('/api/v1/profile', data: request.toJson()),
    );
    return ProfileDto.fromJson(_payload(response.data));
  }

  Future<void> requestForgotPassword(ForgotPasswordRequestDto request) async {
    await _request(
      () => _dio.post('/api/v1/auth/forgot-password', data: request.toJson()),
    );
  }

  Future<void> resetPassword(ResetPasswordRequestDto request) async {
    await _request(
      () => _dio.post('/api/v1/auth/reset-password', data: request.toJson()),
    );
  }

  Future<List<BranchDto>> fetchBranches({
    String? search,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _request(
      () => _dio.get(
        '/api/v1/business-admin/branches',
        queryParameters: {
          'search': search,
          'status': status,
          'page': page,
          'pageSize': pageSize,
        }..removeWhere((_, value) => value == null || value == ''),
      ),
    );
    final data = _payload(response.data);
    final items = data['items'] as List? ?? data['data'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BranchDto.fromJson)
        .toList();
  }

  Future<BranchDto> createBranch(BranchRequestDto request) async {
    final response = await _request(
      () =>
          _dio.post('/api/v1/business-admin/branches', data: request.toJson()),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<BranchDto> updateBranch(
    String branchId,
    BranchRequestDto request,
  ) async {
    final response = await _request(
      () => _dio.put(
        '/api/v1/business-admin/branches/$branchId',
        data: request.toJson(),
      ),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<BranchDto> createBranchManagerAccount(
    String branchId,
    BranchManagerAccountRequestDto request,
  ) async {
    final response = await _request(
      () => _dio.post(
        '/api/v1/business-admin/branches/$branchId/manager-account',
        data: request.toJson(),
      ),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<BranchDto> updateBranchManagerAccount(
    String branchId,
    String managerId,
    BranchManagerAccountRequestDto request,
  ) async {
    final response = await _request(
      () => _dio.put(
        '/api/v1/business-admin/branches/$branchId/manager-account/$managerId',
        data: request.toJson(),
      ),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<BranchDto> resetBranchManagerPassword(
    String branchId,
    String managerId,
  ) async {
    final response = await _request(
      () => _dio.post(
        '/api/v1/business-admin/branches/$branchId/manager-account/$managerId/reset-password',
      ),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<BranchDto> deleteBranchManagerAccount(
    String branchId,
    String managerId,
  ) async {
    final response = await _request(
      () => _dio.delete(
        '/api/v1/business-admin/branches/$branchId/manager-account/$managerId',
      ),
    );
    return BranchDto.fromJson(_payload(response.data));
  }

  Future<MedicineStatisticsDto> fetchMedicineStatistics(
    MedicineStatisticsFilterDto filter,
  ) async {
    final response = await _request(
      () => _dio.get(
        '/api/v1/business-admin/medicine-statistics',
        queryParameters: filter.toQueryParameters(),
      ),
    );
    return MedicineStatisticsDto.fromJson(_payload(response.data));
  }

  Future<BusinessAnalysisReportDto> fetchBusinessAnalysisReport(
    BusinessAnalysisFilterDto filter,
  ) async {
    final response = await _request(
      () => _dio.get(
        '/api/v1/business-admin/reports/business-analysis',
        queryParameters: filter.toQueryParameters(),
      ),
    );
    return BusinessAnalysisReportDto.fromJson(_payload(response.data));
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() operation,
  ) async {
    try {
      return await operation();
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const NetworkTimeoutException();
      }
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        throw const UnauthorizedException();
      }
      throw ServerException(_messageFromResponse(error.response?.data));
    }
  }

  Map<String, dynamic> _payload(Object? data) {
    if (data is Map<String, dynamic>) {
      final wrappedData = data['data'];
      if (wrappedData is Map<String, dynamic>) return wrappedData;
      return data;
    }
    throw const ServerException('Invalid server response.');
  }

  String _messageFromResponse(Object? data) {
    if (data is Map) {
      final message = data['message'] ?? data['title'];
      if (message != null) return message.toString();
      final error = data['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
    }
    return 'Server error. Please try again.';
  }
}
