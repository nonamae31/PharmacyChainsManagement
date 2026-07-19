import 'dart:async';
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

// ===== MOCKS =====
class MockAuthApiClient extends Mock implements AuthApiClient {}
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

// ===== FAKES =====
class FakeLoginRequestDto extends Fake implements LoginRequestDto {}

void main() {
  late MockAuthApiClient mockAuthApiClient;
  late MockLocalAuthentication mockLocalAuth;
  late AuthBloc sut;

  String createFakeJwtToken(String role) {
    final payload = {'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': role, 'exp': (DateTime.now().millisecondsSinceEpoch / 1000) + 3600};
    final base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));
    return 'header.$base64Payload.signature';
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeLoginRequestDto());

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
    sut = AuthBloc(
      authApiClient: mockAuthApiClient,
      localAuth: mockLocalAuth,
    );
  });

  tearDown(() {
    sut.close();
  });

  final tEmail = 'test@gmail.com';
  final tPassword = 'password123';
  final tAuthResult = AuthResultDto(
    accessToken: 'fake_access_token',
    refreshToken: 'fake_refresh_token',
    role: 'SystemAdmin',
    userId: 'user-123',
  );
  final tException = Exception('Unauthorized');

  // ═══════════════════════════════════════════════════
  // STATE TRANSITION TESTING
  // ═══════════════════════════════════════════════════
  group('State Transitions - LoginRequested', () {
    test('initial state should be AuthInitial', () {
      expect(sut.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'ST-V1: should emit [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockAuthApiClient.login(any())).thenAnswer((_) async => tAuthResult);
        return sut;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.role, 'role', 'SystemAdmin'),
      ],
      verify: (_) {
        verify(() => mockAuthApiClient.login(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'ST-V2: should emit [AuthLoading, AuthError] when API throws Exception',
      build: () {
        when(() => mockAuthApiClient.login(any())).thenThrow(tException);
        return sut;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('Unauthorized')),
      ],
    );
  });

  // ═══════════════════════════════════════════════════
  // USE CASE TESTING (Happy Path, Sad Path, etc.)
  // ═══════════════════════════════════════════════════
  group('Use Case Scenarios - BiometricLoginRequested', () {
    group('Happy Path', () {
      blocTest<AuthBloc, AuthState>(
        'UC-HP: should complete successfully when biometric is supported and authenticated',
        build: () {
          when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
          when(() => mockLocalAuth.authenticate(localizedReason: any(named: 'localizedReason')))
              .thenAnswer((_) async => true);
          return sut;
        },
        act: (bloc) => bloc.add(BiometricLoginRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having((s) => s.role, 'role', 'User'),
        ],
      );
    });

    group('Alternative Paths', () {
      blocTest<AuthBloc, AuthState>(
        'UC-AP1: should emit AuthError when user cancels authentication',
        build: () {
          when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
          when(() => mockLocalAuth.authenticate(localizedReason: any(named: 'localizedReason')))
              .thenAnswer((_) async => false);
          return sut;
        },
        act: (bloc) => bloc.add(BiometricLoginRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having((s) => s.message, 'message', contains('Biometric authentication failed')),
        ],
      );
    });

    group('Exception Paths', () {
      blocTest<AuthBloc, AuthState>(
        'UC-EP1: should emit AuthError when biometrics are not supported on the device',
        build: () {
          when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
          when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);
          return sut;
        },
        act: (bloc) => bloc.add(BiometricLoginRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having((s) => s.message, 'message', contains('not supported')),
        ],
      );
    });
  });

  // ═══════════════════════════════════════════════════
  // ERROR GUESSING
  // ═══════════════════════════════════════════════════
  group('Error Guessing - LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'EG-01: should handle empty email and password strings gracefully (API error simulation)',
      build: () {
        when(() => mockAuthApiClient.login(any())).thenThrow(Exception('Invalid inputs'));
        return sut;
      },
      act: (bloc) => bloc.add(LoginRequested('', '')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('Invalid inputs')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'EG-02: should throw/catch TimeoutException gracefully',
      build: () {
        when(() => mockAuthApiClient.login(any())).thenThrow(TimeoutException('Connection timeout'));
        return sut;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', contains('TimeoutException')),
      ],
    );
  });
}
