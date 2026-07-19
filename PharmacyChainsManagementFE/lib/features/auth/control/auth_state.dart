import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  
  const AuthAuthenticated(this.role);

  @override
  List<Object> get props => [role];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

final class PasswordResetRequestSuccess extends AuthState {
  final String message;

  const PasswordResetRequestSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class ForgotPasswordSendEmailSuccess extends AuthState {
  final String message;
  const ForgotPasswordSendEmailSuccess(this.message);
  @override
  List<Object> get props => [message];
}

final class ForgotPasswordVerifyCodeSuccess extends AuthState {
  final String message;
  const ForgotPasswordVerifyCodeSuccess(this.message);
  @override
  List<Object> get props => [message];
}

final class ForgotPasswordResetSuccess extends AuthState {
  final String message;
  const ForgotPasswordResetSuccess(this.message);
  @override
  List<Object> get props => [message];
}
