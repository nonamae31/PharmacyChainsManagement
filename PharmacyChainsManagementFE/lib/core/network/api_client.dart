import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/auth/network/secure_storage_service.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:7000',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await SecureStorageService.readRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:7000'));
              final refreshResponse = await refreshDio.post(
                '/api/v1/auth/refresh',
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken = refreshResponse.data['accessToken'] ?? refreshResponse.data['access_token'];
              final newRefreshToken = refreshResponse.data['refreshToken'] ?? refreshResponse.data['refresh_token'];
              
              if (newAccessToken != null) {
                await SecureStorageService.saveToken(newAccessToken);
                if (newRefreshToken != null) {
                  await SecureStorageService.saveRefreshToken(newRefreshToken);
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
    ));

    // TODO (SECURITY): Bật SSL Pinning khi có certificate từ server
    return dio;
  }
}
