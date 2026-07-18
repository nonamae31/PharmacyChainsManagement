import 'package:flutter/foundation.dart';

/// Resolves the backend base URL for the current run target.
///
/// The Android emulator cannot reach the host machine's `localhost` directly
/// — it must use the special `10.0.2.2` NAT alias instead. Every other
/// target (web, Windows/macOS/Linux desktop, iOS simulator) shares the host
/// network and can reach the backend via `localhost` directly.
String resolveApiBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:7000';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:7000';
  }
  return 'http://localhost:7000';
}
