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
      accessToken: (json['token'] ?? json['access_token'])?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      role: (json['roleCode'] ?? json['role'])?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'])?.toString() ?? '',
    );
  }
}
