import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage_service.dart';
import '../../../core/app_logger.dart';
import '../../../core/network/api_base_url.dart';
import '../entity/login_request_dto.dart';
import '../entity/auth_result_dto.dart';
import '../../../core/exceptions.dart';

class AuthApiClient {
  late final Dio _dio;

  AuthApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    // TODO (SECURITY): Bật SSL Pinning khi có certificate từ server
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            AppLogger.info('401 detected, attempting to refresh token');
            final success = await _refreshToken();
            if (success) {
              final newToken = await SecureStorageService.readToken();
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              AppLogger.error('Refresh token failed');
              await SecureStorageService.clearAll();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<AuthResultDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );
      return AuthResultDto.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Login error', e);
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final data = e.response!.data as Map;
          if (data.containsKey('message') && data['message'] != null) {
            throw ServerException(data['message'].toString());
          } else if (data.containsKey('title') && data['title'] != null) {
            throw ServerException(data['title'].toString());
          }
        }
        if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
          throw const ServerException('Email hoặc mật khẩu không chính xác.');
        }
        throw const ServerException('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
      }
      throw const ServerException('Đã xảy ra lỗi không xác định.');
    }
  }

  Future<AuthResultDto> register(LoginRequestDto request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      return AuthResultDto.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Register error', e);
      if (e is DioException && e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('title')) {
          throw ServerException(data['title'].toString());
        } else if (data.containsKey('message')) {
          throw ServerException(data['message'].toString());
        }
      }
      throw const ServerException('Không thể đăng ký. Vui lòng thử lại.');
    }
  }

  Future<AuthResultDto> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/google-login',
        data: {'idToken': idToken},
      );
      return AuthResultDto.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Google login error', e);
      if (e is DioException && e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('message') && data['message'] != null) {
          throw ServerException(data['message'].toString());
        } else if (data.containsKey('title') && data['title'] != null) {
          throw ServerException(data['title'].toString());
        }
      }
      throw const ServerException('Đăng nhập Google thất bại.');
    }
  }

  Future<String> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );
      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Verification code has been sent successfully.';
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ServerException(data['message'].toString());
      }
      throw const ServerException('Unable to send the verification code.');
    }
  }

  Future<String> verifyCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/verify-code',
        data: {'email': email, 'code': code},
      );
      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Verification code is valid.';
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ServerException(data['message'].toString());
      }
      throw const ServerException('Invalid verification code.');
    }
  }

  Future<String> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/reset-password',
        data: {'email': email, 'token': code, 'newPassword': newPassword},
      );
      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Your password has been successfully reset.';
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ServerException(data['message'].toString());
      }
      throw const ServerException('Failed to reset your password.');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorageService.readRefreshToken();
      if (refreshToken == null) return false;
      
      final dio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? resolveApiBaseUrl()));
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      final result = AuthResultDto.fromJson(response.data);
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      return true;
    } catch (e) {
      AppLogger.error('Failed to refresh token', e);
      return false;
    }
  }
}
