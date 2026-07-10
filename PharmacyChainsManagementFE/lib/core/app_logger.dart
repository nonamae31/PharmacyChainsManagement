import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error != null ? ': $error' : ''}');
    }
  }

  static String maskToken(String token) {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 8)}...***';
  }
}
