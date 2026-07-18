sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

final class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException() : super('Network timeout. Please try again.');
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Your session has expired.');
}

final class ServerException extends AppException {
  const ServerException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException(super.message);
}
