import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class BiometricLoginRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class GoogleLoginRequested extends AuthEvent {}

final class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

final class ForgotPasswordEmailSubmitted extends AuthEvent {
  final String email;
  const ForgotPasswordEmailSubmitted(this.email);
  @override
  List<Object> get props => [email];
}

final class ForgotPasswordCodeVerified extends AuthEvent {
  final String email;
  final String code;
  const ForgotPasswordCodeVerified(this.email, this.code);
  @override
  List<Object> get props => [email, code];
}

final class ForgotPasswordResetRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;
  const ForgotPasswordResetRequested(this.email, this.code, this.newPassword);
  @override
  List<Object> get props => [email, code, newPassword];
}

class LogoutRequested extends AuthEvent {}
