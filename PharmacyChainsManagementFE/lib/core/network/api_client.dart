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
    ));

    // TODO (SECURITY): Bật SSL Pinning khi có certificate từ server
    return dio;
  }
}
