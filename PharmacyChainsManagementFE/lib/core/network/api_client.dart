import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/auth/network/secure_storage_service.dart';
import 'api_base_url.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? resolveApiBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
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
            final accessToken = await SecureStorageService.readToken();
            final refreshToken = await SecureStorageService.readRefreshToken();
            if (accessToken != null &&
                accessToken.isNotEmpty &&
                refreshToken != null &&
                refreshToken.isNotEmpty) {
              try {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: dotenv.env['BASE_URL'] ?? resolveApiBaseUrl(),
                    headers: {
                      'Content-Type': 'application/json',
                      'X-Client-Type': 'Mobile',
                    },
                  ),
                );
                final refreshResponse = await refreshDio.post(
                  '/api/v1/auth/refresh',
                  data: {
                    'accessToken': accessToken,
                    'refreshToken': refreshToken,
                  },
                );

                final responseData = refreshResponse.data;
                final tokenData =
                    responseData is Map && responseData['data'] is Map
                    ? responseData['data'] as Map
                    : responseData as Map;
                final newAccessToken =
                    tokenData['accessToken'] ?? tokenData['access_token'];
                final newRefreshToken =
                    tokenData['refreshToken'] ?? tokenData['refresh_token'];

                if (newAccessToken != null) {
                  await SecureStorageService.saveToken(newAccessToken);
                  if (newRefreshToken != null) {
                    await SecureStorageService.saveRefreshToken(
                      newRefreshToken,
                    );
                  }

                  // Retry the original request
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';

                  final cloneReq = await dio.request(
                    opts.path,
                    options: Options(
                      method: opts.method,
                      headers: opts.headers,
                    ),
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                  );
                  return handler.resolve(cloneReq);
                }
              } catch (e) {
                await SecureStorageService.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // TODO (SECURITY): Bật SSL Pinning khi có certificate từ server
    return dio;
  }
}
