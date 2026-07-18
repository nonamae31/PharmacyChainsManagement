sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException() : super('Kết nối mạng bị gián đoạn.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Phiên đăng nhập đã hết hạn.');
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
