import '../constants/branch_manager_app_strings.dart';

sealed class BranchManagerAppException implements Exception {
  final String message;
  const BranchManagerAppException(this.message);

  @override
  String toString() => message;
}

final class BranchManagerTimeoutException extends BranchManagerAppException {
  const BranchManagerTimeoutException() : super(AppStrings.requestTimedOut);
}

final class BranchManagerUnauthorizedException extends BranchManagerAppException {
  const BranchManagerUnauthorizedException() : super(AppStrings.unauthorized);
}

final class BranchManagerServerException extends BranchManagerAppException {
  const BranchManagerServerException(super.message);
}
