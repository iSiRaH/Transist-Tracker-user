import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:transist_tracker/services/auth_service.dart';
import 'package:transist_tracker/services/onboarding_storage_service.dart';
import 'package:transist_tracker/services/secure_storage_service.dart';

enum AuthStatus { unauthenticated, authenticated }

enum AuthScreen { login, signup }

class AuthState {
  final bool isInitializing;
  final bool hasCompletedOnboarding;
  final bool isSubmitting;
  final AuthStatus authStatus;
  final AuthScreen authScreen;
  final String? errorMessage;

  const AuthState({
    required this.isInitializing,
    required this.hasCompletedOnboarding,
    required this.isSubmitting,
    required this.authStatus,
    required this.authScreen,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      isInitializing: true,
      hasCompletedOnboarding: false,
      isSubmitting: false,
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
    );
  }

  AuthState copyWith({
    bool? isInitializing,
    bool? hasCompletedOnboarding,
    bool? isSubmitting,
    AuthStatus? authStatus,
    AuthScreen? authScreen,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authStatus: authStatus ?? this.authStatus,
      authScreen: authScreen ?? this.authScreen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final onboardingStorageServiceProvider =
    Provider<OnboardingStorageService>((ref) {
  return OnboardingStorageService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  late final AuthNotifier notifier;

  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final onboardingStorageService = ref.watch(onboardingStorageServiceProvider);

  final authService = AuthService(
    secureStorageService: secureStorageService,
    onUnauthorized: () {
      notifier.handleUnauthorized();
    },
  );

  notifier = AuthNotifier(
    authService: authService,
    onboardingStorageService: onboardingStorageService,
  );

  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final OnboardingStorageService _onboardingStorageService;

  AuthNotifier({
    required AuthService authService,
    required OnboardingStorageService onboardingStorageService,
  })  : _authService = authService,
        _onboardingStorageService = onboardingStorageService,
        super(AuthState.initial()) {
    initialize();
  }

  Future<void> initialize() async {
    final onboardingCompleted =
        await _onboardingStorageService.isOnboardingCompleted();

    if (!onboardingCompleted) {
      state = state.copyWith(
        isInitializing: false,
        hasCompletedOnboarding: false,
        authStatus: AuthStatus.unauthenticated,
        authScreen: AuthScreen.login,
        clearError: true,
      );
      return;
    }

    final token = await _authService.getSavedToken();
    final hasValidToken =
        token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);

    if (hasValidToken) {
      state = state.copyWith(
        isInitializing: false,
        hasCompletedOnboarding: true,
        authStatus: AuthStatus.authenticated,
        clearError: true,
      );
      return;
    }

    await _authService.clearSession();
    state = state.copyWith(
      isInitializing: false,
      hasCompletedOnboarding: true,
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      clearError: true,
    );
  }

  Future<void> completeOnboarding() async {
    await _onboardingStorageService.setOnboardingCompleted();
    state = state.copyWith(
      hasCompletedOnboarding: true,
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      clearError: true,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final token = await _authService.login(email: email, password: password);
      await _authService.saveSession(token);

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        hasCompletedOnboarding: true,
        clearError: true,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: _resolveErrorMessage(error, fallback: 'Login failed'),
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Login failed',
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final token = await _authService.signup(
          name: name, email: email, password: password);
      await _authService.saveSession(token);

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        hasCompletedOnboarding: true,
        clearError: true,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: _resolveErrorMessage(error, fallback: 'Signup failed'),
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Signup failed',
      );
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      isSubmitting: false,
      hasCompletedOnboarding: true,
      clearError: true,
    );
  }

  Future<void> handleUnauthorized() async {
    await logout();
  }

  void showSignup() {
    state = state.copyWith(authScreen: AuthScreen.signup, clearError: true);
  }

  void showLogin() {
    state = state.copyWith(authScreen: AuthScreen.login, clearError: true);
  }

  String _resolveErrorMessage(DioException error, {required String fallback}) {
    final payload = error.response?.data;
    final payloadMessage = _extractMessage(payload);
    if (payloadMessage != null && payloadMessage.isNotEmpty) {
      return payloadMessage;
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }

    return fallback;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      const keys = <String>['message', 'error', 'detail'];

      for (final key in keys) {
        final value = payload[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }

      final nestedData = payload['data'];
      if (nestedData != null) {
        final nestedMessage = _extractMessage(nestedData);
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    if (payload is List) {
      for (final item in payload) {
        final nestedMessage = _extractMessage(item);
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return null;
  }
}
