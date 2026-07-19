import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../entity/login_request_dto.dart';
import '../network/auth_api_client.dart';
import '../network/secure_storage_service.dart';
import '../../../core/app_logger.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiClient authApiClient;
  final LocalAuthentication localAuth;

  AuthBloc({required this.authApiClient, required this.localAuth})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<ForgotPasswordEmailSubmitted>(_onForgotPasswordEmailSubmitted);
    on<ForgotPasswordCodeVerified>(_onForgotPasswordCodeVerified);
    on<ForgotPasswordResetRequested>(_onForgotPasswordResetRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      var token = await SecureStorageService.readToken();
      if (token != null && token.isNotEmpty) {
        var payloadMap = _decodeJwtPayload(token);
        if (_isTokenExpired(payloadMap)) {
          final refreshed = await authApiClient.refreshSession();
          if (!refreshed) {
            await SecureStorageService.clearAll();
            emit(AuthInitial());
            return;
          }
          token = await SecureStorageService.readToken();
          payloadMap = token == null ? null : _decodeJwtPayload(token);
        }

        final role =
            payloadMap?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
            payloadMap?['role'];
        if (role != null) {
          emit(AuthAuthenticated(role.toString()));
          return;
        }
      }
    } catch (error) {
      AppLogger.error('Auth check error', error);
      await SecureStorageService.clearAll();
    }
    emit(AuthInitial());
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = json.decode(payload);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  bool _isTokenExpired(Map<String, dynamic>? payload) {
    final expiresAt = payload?['exp'];
    if (expiresAt is! num) {
      return true;
    }
    final expiration = DateTime.fromMillisecondsSinceEpoch(
      expiresAt.toInt() * 1000,
      isUtc: true,
    );
    return !expiration.isAfter(
      DateTime.now().toUtc().add(const Duration(seconds: 30)),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await authApiClient.requestPasswordReset(event.email);
      emit(PasswordResetRequestSuccess(message));
    } catch (error) {
      AppLogger.error('Password reset request failed', error);
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onForgotPasswordEmailSubmitted(
    ForgotPasswordEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await authApiClient.requestPasswordReset(event.email);
      emit(ForgotPasswordSendEmailSuccess(message));
    } catch (error) {
      AppLogger.error('Forgot password email submit failed', error);
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onForgotPasswordCodeVerified(
    ForgotPasswordCodeVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await authApiClient.verifyCode(event.email, event.code);
      emit(ForgotPasswordVerifyCodeSuccess(message));
    } catch (error) {
      AppLogger.error('Forgot password verification failed', error);
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onForgotPasswordResetRequested(
    ForgotPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await authApiClient.resetPassword(
        event.email,
        event.code,
        event.newPassword,
      );
      emit(ForgotPasswordResetSuccess(message));
    } catch (error) {
      AppLogger.error('Forgot password reset failed', error);
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestDto(
        email: event.email,
        password: event.password,
      );
      final result = await authApiClient.login(request);

      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info(
        'Auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}',
      );

      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Login request failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestDto(
        email: event.email,
        password: event.password,
      );
      final result = await authApiClient.register(request);

      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info(
        'Register success, token prefix: ${AppLogger.maskToken(result.accessToken)}',
      );

      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Register request failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        emit(const AuthError('Không thể lấy Firebase ID token.'));
        return;
      }

      final result = await authApiClient.googleLogin(idToken);

      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info(
        'Firebase Google auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}',
      );
      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Firebase Google auth failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        emit(
          const AuthError(
            'Biometric authentication not supported on this device.',
          ),
        );
        return;
      }

      final authenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
      );

      if (authenticated) {
        final token = await SecureStorageService.readToken();
        if (token != null && token.isNotEmpty) {
          emit(const AuthAuthenticated('User'));
        } else {
          emit(
            const AuthError(
              'No active session found. Please login with credentials first.',
            ),
          );
        }
      } else {
        emit(const AuthError('Biometric authentication failed.'));
      }
    } catch (e) {
      AppLogger.error('Biometric authentication error', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await SecureStorageService.clearAll();
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '186467490377-boumjq0i8ms7uhkpqs4ejpbvpo2ol8fp.apps.googleusercontent.com',
      );
      try {
        await googleSignIn.signOut();
      } catch (e) {
        AppLogger.error('Google sign-out skipped', e);
      }
      AppLogger.info('Logout successful');
      emit(AuthInitial());
    } catch (e) {
      AppLogger.error('Logout error', e);
      emit(AuthError(e.toString()));
    }
  }
}
