import 'package:equatable/equatable.dart';

class AuthResultDto extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String userId;

  const AuthResultDto({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
  });

  factory AuthResultDto.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    final user = _asMap(data['user']);
    final roleData = _asMap(data['role']);

    return AuthResultDto(
      accessToken:
          (data['accessToken'] ?? data['token'] ?? data['access_token'])
              ?.toString() ??
          '',
      refreshToken:
          (data['refreshToken'] ?? data['refresh_token'])?.toString() ?? '',
      role:
          (data['roleCode'] ??
                  roleData?['roleCode'] ??
                  roleData?['role_code'] ??
                  (data['role'] is String ? data['role'] : null))
              ?.toString() ??
          '',
      userId:
          (data['userId'] ??
                  data['user_id'] ??
                  user?['userId'] ??
                  user?['user_id'] ??
                  user?['id'])
              ?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'roleCode': role,
    'userId': userId,
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, role, userId];

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}
