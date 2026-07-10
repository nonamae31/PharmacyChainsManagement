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
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestDto(email: event.email, password: event.password);
      final result = await authApiClient.login(request);
      
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info('Auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}');
      
      emit(AuthSuccess(result.role));
    } catch (e) {
      AppLogger.error('Login request failed', e);
      emit(AuthFailure(e.toString()));
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
      
      emit(AuthSuccess(result.role));
    } catch (e) {
      AppLogger.error('Register request failed', e);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        emit(const AuthFailure('Không thể lấy Google ID token.'));
        return;
      }
      final result = await authApiClient.googleLogin(idToken);
      
      await SecureStorageService.saveToken(result.accessToken);
      await SecureStorageService.saveRefreshToken(result.refreshToken);
      AppLogger.info('Google auth success, token prefix: ${AppLogger.maskToken(result.accessToken)}');
      
      emit(AuthSuccess(result.role));
    } catch (e) {
      AppLogger.error('Google auth failed', e);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        emit(const AuthFailure('Biometric authentication not supported on this device.'));
        return;
      }
      
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        
      );
      
      if (authenticated) {
        final token = await SecureStorageService.readToken();
        if (token != null && token.isNotEmpty) {
          // Defaults to User role via biometrics without an API call if offline,
          // though typically this should verify against backend or decoded JWT
          emit(const AuthSuccess('User'));
        } else {
          emit(const AuthFailure('No active session found. Please login with credentials first.'));
        }
      } else {
        emit(const AuthFailure('Biometric authentication failed.'));
      }
    } catch (e) {
      AppLogger.error('Biometric authentication error', e);
      emit(AuthFailure(e.toString()));
    }
  }
}
