import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pharmacy_chains_management_fe/features/auth/control/auth_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/auth/control/auth_event.dart';
import 'package:pharmacy_chains_management_fe/features/auth/control/auth_state.dart';
import 'package:pharmacy_chains_management_fe/features/auth/network/auth_api_client.dart';
import 'package:pharmacy_chains_management_fe/features/auth/entity/login_request_dto.dart';
import 'package:pharmacy_chains_management_fe/features/auth/entity/auth_result_dto.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. Tạo Mock Classes
class MockAuthApiClient extends Mock implements AuthApiClient {}
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

// 2. Fallback value
class FakeLoginRequestDto extends Fake implements LoginRequestDto {}

void main() {
  late MockAuthApiClient mockAuthApiClient;
  late MockLocalAuthentication mockLocalAuth;
  late AuthBloc authBloc;

  // Helper function để tạo JWT Token giả (phần Payload)
  String createFakeJwtToken(String role) {
    final payload = {'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': role};
    final base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));
    return 'header.$base64Payload.signature';
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeLoginRequestDto());
    
    // Giả lập platform channel cho flutter_secure_storage để tránh MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          if (methodCall.arguments['key'] == 'access_token') {
            return createFakeJwtToken('SystemAdmin');
          }
          return null;
        }
        return null;
      },
    );
  });

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();
    mockLocalAuth = MockLocalAuthentication();
    authBloc = AuthBloc(
      authApiClient: mockAuthApiClient,
      localAuth: mockLocalAuth,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tEmail = 'test@gmail.com';
  final tPassword = 'password123';
  final tAuthResult = AuthResultDto(
    accessToken: 'fake_access_token',
    refreshToken: 'fake_refresh_token',
    role: 'SystemAdmin',
    userId: 'user-123',
  );

  // ==========================================
  // Nhóm 1: LoginRequested
  // ==========================================
  group('AuthBloc - LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'Thành công: emits [AuthLoading, AuthAuthenticated]',
      build: () {
        when(() => mockAuthApiClient.login(any())).thenAnswer((_) async => tAuthResult);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.role, 'role', 'SystemAdmin'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Thất bại: emits [AuthLoading, AuthError] khi API quăng Exception',
      build: () {
        when(() => mockAuthApiClient.login(any()))
            .thenThrow(Exception('Unauthorized'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('Unauthorized')),
      ],
    );
  });

  // ==========================================
  // Nhóm 2: RegisterRequested
  // ==========================================
  group('AuthBloc - RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'Thành công: emits [AuthLoading, AuthAuthenticated]',
      build: () {
        when(() => mockAuthApiClient.register(any())).thenAnswer((_) async => tAuthResult);
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.role, 'role', 'SystemAdmin'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Thất bại: emits [AuthLoading, AuthError] khi API lỗi',
      build: () {
        when(() => mockAuthApiClient.register(any()))
            .thenThrow(Exception('Email already exists'));
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('Email already exists')),
      ],
    );
  });

  // ==========================================
  // Nhóm 3: BiometricLoginRequested
  // ==========================================
  group('AuthBloc - BiometricLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'Biometric không hỗ trợ: emits [AuthLoading, AuthError]',
      build: () {
        when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(BiometricLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('not supported')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Người dùng hủy xác thực (authenticate = false): emits [AuthLoading, AuthError]',
      build: () {
        when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(localizedReason: any(named: 'localizedReason')))
            .thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(BiometricLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('failed')),
      ],
    );
    
    // Lưu ý: Test pass xác thực sinh trắc học phụ thuộc vào Storage
    blocTest<AuthBloc, AuthState>(
      'Thành công: emits [AuthLoading, AuthAuthenticated]',
      build: () {
        when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(localizedReason: any(named: 'localizedReason')))
            .thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(BiometricLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.role, 'role', 'User'), // 'User' hardcode
      ],
    );
  });
}
