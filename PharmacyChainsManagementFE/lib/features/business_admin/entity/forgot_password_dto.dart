import 'package:equatable/equatable.dart';

class ForgotPasswordRequestDto extends Equatable {
  final String email;

  const ForgotPasswordRequestDto(this.email);

  Map<String, dynamic> toJson() => {'email': email};

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequestDto extends Equatable {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordRequestDto({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'token': token,
    'newPassword': newPassword,
  };

  @override
  List<Object?> get props => [email, token, newPassword];
}
