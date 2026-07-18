import 'package:google_sign_in/google_sign_in.dart';
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

  AuthBloc({required this.authApiClient, required this.localAuth}) : super(AuthInitial()) {
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

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestDto(email: event.email, password: event.password);
      final result = await authApiClient.login(request);
      
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info('Auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}');
      
      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Login request failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestDto(email: event.email, password: event.password);
      final result = await authApiClient.register(request);
      
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info('Register success, token prefix: ${AppLogger.maskToken(result.accessToken)}');
      
      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Register request failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '186467490377-boumjq0i8ms7uhkpqs4ejpbvpo2ol8fp.apps.googleusercontent.com',
        scopes: ['email', 'profile', 'openid'],
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        emit(const AuthError('Đăng nhập Google bị hủy.'));
        return;
      }
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        emit(const AuthError('Không thể lấy Google ID token.'));
        return;
      }
      final result = await authApiClient.googleLogin(idToken);
      
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info('Google auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}');
      
      emit(AuthAuthenticated(result.role));
    } catch (e) {
      AppLogger.error('Google auth failed', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        emit(const AuthError('Biometric authentication not supported on this device.'));
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
          emit(const AuthError('No active session found. Please login with credentials first.'));
        }
      } else {
        emit(const AuthError('Biometric authentication failed.'));
      }
    } catch (e) {
      AppLogger.error('Biometric authentication error', e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await SecureStorageService.clearAll();
      final googleSignIn = GoogleSignIn(
        serverClientId: '186467490377-boumjq0i8ms7uhkpqs4ejpbvpo2ol8fp.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      AppLogger.info('Logout successful');
      emit(AuthInitial());
    } catch (e) {
      AppLogger.error('Logout error', e);
      emit(AuthError(e.toString()));
    }
  }
}
