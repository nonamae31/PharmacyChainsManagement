import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/auth/entity/auth_result_dto.dart';
import 'package:pharmacy_chains_management_fe/features/auth/entity/login_request_dto.dart';

void main() {
  group('🔐 Auth Unit Test - LoginRequestDto', () {
    test('toJson() chuyển đổi chính xác dữ liệu email và password sang Map json', () {
      final dto = LoginRequestDto(
        email: 'manager@pharmacy.vn',
        password: 'Password123!',
      );

      final json = dto.toJson();

      expect(json['email'], equals('manager@pharmacy.vn'));
      expect(json['password'], equals('Password123!'));
    });
  });

  group('🔐 Auth Unit Test - AuthResultDto', () {
    test('fromJson() parse chuẩn xác chuỗi token và thông tin người dùng từ server', () {
      final jsonResponse = {
        'token': 'jwt_access_token_mock_string',
        'refresh_token': 'jwt_refresh_token_mock_string',
        'roleCode': 'WAREHOUSE_MANAGER',
        'userId': 'USER-8899',
      };

      final authResult = AuthResultDto.fromJson(jsonResponse);

      expect(authResult.accessToken, equals('jwt_access_token_mock_string'));
      expect(authResult.refreshToken, equals('jwt_refresh_token_mock_string'));
      expect(authResult.role, equals('WAREHOUSE_MANAGER'));
      expect(authResult.userId, equals('USER-8899'));
    });

    test('fromJson() xử lý mượt mà khi server trả về key fallback (access_token, role, user_id)', () {
      final jsonResponse = {
        'access_token': 'fallback_token_123',
        'role': 'ADMIN',
        'user_id': 'USER-1122',
      };

      final authResult = AuthResultDto.fromJson(jsonResponse);

      expect(authResult.accessToken, equals('fallback_token_123'));
      expect(authResult.role, equals('ADMIN'));
      expect(authResult.userId, equals('USER-1122'));
    });

    test('fromJson() parses camelCase tokens and nested user and role', () {
      final jsonResponse = {
        'accessToken': 'staff_access_token',
        'refreshToken': 'staff_refresh_token',
        'user': {'userId': 'STAFF-001'},
        'role': {
          'roleId': 3,
          'roleCode': 'STAFF',
          'roleName': 'Staff',
        },
      };

      final authResult = AuthResultDto.fromJson(jsonResponse);

      expect(authResult.accessToken, equals('staff_access_token'));
      expect(authResult.refreshToken, equals('staff_refresh_token'));
      expect(authResult.role, equals('STAFF'));
      expect(authResult.userId, equals('STAFF-001'));
    });

    test('fromJson() unwraps an ApiResponse data payload', () {
      final jsonResponse = {
        'success': true,
        'message': 'Token refreshed successfully',
        'data': {
          'accessToken': 'refreshed_access_token',
          'refreshToken': 'refreshed_refresh_token',
          'user': {'userId': 'STAFF-002'},
          'role': {'roleCode': 'STAFF'},
        },
      };

      final authResult = AuthResultDto.fromJson(jsonResponse);

      expect(authResult.accessToken, equals('refreshed_access_token'));
      expect(authResult.refreshToken, equals('refreshed_refresh_token'));
      expect(authResult.role, equals('STAFF'));
      expect(authResult.userId, equals('STAFF-002'));
    });
  });
}
