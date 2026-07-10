class AuthResultDto {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String userId;

  AuthResultDto({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
  });

  factory AuthResultDto.fromJson(Map<String, dynamic> json) {
    return AuthResultDto(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      role: json['role'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}
