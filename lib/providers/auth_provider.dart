import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:transist_tracker/models/User.dart';
import 'package:transist_tracker/providers/navigation_provider.dart';
import 'package:transist_tracker/services/auth_service.dart';
import 'package:transist_tracker/services/google_auth_service.dart';
import 'package:transist_tracker/services/onboarding_storage_service.dart';
import 'package:transist_tracker/services/secure_storage_service.dart';

enum AuthStatus { unauthenticated, authenticated }

enum AuthScreen { login, signup, forgotPassword }

class AuthState {
  final bool isInitializing;
  final bool hasCompletedOnboarding;
  final bool isSubmitting;
  final AuthStatus authStatus;
  final AuthScreen authScreen;
  final User? currentUser;
  final String? errorMessage;
  final String? successMessage;
  final String? pendingResetEmail;
  final String? pendingResetCode;

  const AuthState({
    required this.isInitializing,
    required this.hasCompletedOnboarding,
    required this.isSubmitting,
    required this.authStatus,
    required this.authScreen,
    this.currentUser,
    this.errorMessage,
    this.successMessage,
    this.pendingResetEmail,
    this.pendingResetCode,
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
    User? currentUser,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? pendingResetEmail,
    String? pendingResetCode,
    bool clearPendingReset = false,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authStatus: authStatus ?? this.authStatus,
      authScreen: authScreen ?? this.authScreen,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      pendingResetEmail: clearPendingReset
          ? null
          : (pendingResetEmail ?? this.pendingResetEmail),
      pendingResetCode: clearPendingReset
          ? null
          : (pendingResetCode ?? this.pendingResetCode),
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

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  late final AuthNotifier notifier;

  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final onboardingStorageService = ref.watch(onboardingStorageServiceProvider);
  final googleAuthService = ref.watch(googleAuthServiceProvider);

  final authService = AuthService(
    secureStorageService: secureStorageService,
    onUnauthorized: () {
      notifier.handleUnauthorized();
    },
  );

  notifier = AuthNotifier(
    authService: authService,
    onboardingStorageService: onboardingStorageService,
    googleAuthService: googleAuthService,
    ref: ref,
  );

  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final OnboardingStorageService _onboardingStorageService;
  final GoogleAuthService _googleAuthService;
  final Ref _ref;

  AuthNotifier({
    required AuthService authService,
    required OnboardingStorageService onboardingStorageService,
    required GoogleAuthService googleAuthService,
    required Ref ref,
  })  : _authService = authService,
        _onboardingStorageService = onboardingStorageService,
        _googleAuthService = googleAuthService,
        _ref = ref,
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
        clearSuccess: true,
      );
      return;
    }

    final token = await _authService.getSavedToken();
    final hasValidToken =
        token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);

    if (hasValidToken) {
      User? restoredUser = await _authService.getSavedUser();
      if (restoredUser == null) {
        try {
          restoredUser = await _authService.fetchCurrentUser();
          await _authService.saveSession(token, restoredUser);
        } catch (_) {}
      }

      state = state.copyWith(
        isInitializing: false,
        hasCompletedOnboarding: true,
        authStatus: AuthStatus.authenticated,
        currentUser: restoredUser,
        clearError: true,
        clearSuccess: true,
      );
      return;
    }

    await _authService.clearSession();
    state = state.copyWith(
      isInitializing: false,
      hasCompletedOnboarding: true,
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      clearUser: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> completeOnboarding() async {
    await _onboardingStorageService.setOnboardingCompleted();
    state = state.copyWith(
      hasCompletedOnboarding: true,
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final res = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      await _authService.saveSession(res.token, res.user);

      // Redirect to Dashboard (BusDetailsPage / Index 0)
      _ref.read(navigationIndexProvider.notifier).state = 0;

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        hasCompletedOnboarding: true,
        currentUser: res.user,
        clearError: true,
        clearPendingReset: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: _resolveErrorMessage(error, fallback: 'Login failed. Please check your credentials.'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Unable to connect to server. Please try again.',
      );
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final res = await _authService.signup(
        name: name,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phone: phone,
        rememberMe: rememberMe,
      );

      await _authService.saveSession(res.token, res.user);

      // Redirect to Dashboard
      _ref.read(navigationIndexProvider.notifier).state = 0;

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        hasCompletedOnboarding: true,
        currentUser: res.user,
        clearError: true,
        clearPendingReset: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: _resolveErrorMessage(error, fallback: 'Signup failed. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Unable to connect to server. Please try again.',
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final googleUser = await _googleAuthService.signIn();
      if (googleUser == null) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      final res = await _authService.loginWithGoogle(
        idToken: googleUser.idToken,
        email: googleUser.email,
        name: googleUser.displayName,
        googleId: googleUser.id,
        profileImage: googleUser.photoUrl,
        rememberMe: true,
      );

      await _authService.saveSession(res.token, res.user);

      // Redirect to Dashboard
      _ref.read(navigationIndexProvider.notifier).state = 0;

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        hasCompletedOnboarding: true,
        currentUser: res.user,
        clearError: true,
        clearPendingReset: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _resolveErrorMessage(
          error,
          fallback: 'Google sign-in failed. Please try again.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Google sign-in was interrupted. Please try again.',
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final res = await _authService.forgotPassword(email: email);

      state = state.copyWith(
        isSubmitting: false,
        pendingResetEmail: res.email ?? email,
        pendingResetCode: res.resetCode,
        successMessage: res.message,
        clearError: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _resolveErrorMessage(
          error,
          fallback: 'Failed to send verification code. Please try again.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to connect to server. Please try again.',
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirm,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final res = await _authService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        passwordConfirm: passwordConfirm,
      );

      // Auto-login user with the reset token
      await _authService.saveSession(res.token, res.user);

      // Redirect to Dashboard
      _ref.read(navigationIndexProvider.notifier).state = 0;

      state = state.copyWith(
        isSubmitting: false,
        authStatus: AuthStatus.authenticated,
        currentUser: res.user,
        clearError: true,
        clearPendingReset: true,
        successMessage: 'Password reset successfully! Welcome back.',
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _resolveErrorMessage(
          error,
          fallback: 'Failed to reset password. Please verify your code and try again.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to connect to server. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();
    await _googleAuthService.signOut();
    _ref.read(navigationIndexProvider.notifier).state = 0;
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      authScreen: AuthScreen.login,
      clearUser: true,
      isSubmitting: false,
      hasCompletedOnboarding: true,
      clearError: true,
      clearSuccess: true,
      clearPendingReset: true,
    );
  }

  Future<void> handleUnauthorized() async {
    await logout();
  }

  void showSignup() {
    state = state.copyWith(
      authScreen: AuthScreen.signup,
      clearError: true,
      clearSuccess: true,
    );
  }

  void showLogin() {
    state = state.copyWith(
      authScreen: AuthScreen.login,
      clearError: true,
      clearSuccess: true,
    );
  }

  void showForgotPassword() {
    state = state.copyWith(
      authScreen: AuthScreen.forgotPassword,
      clearError: true,
      clearSuccess: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  String _resolveErrorMessage(DioException error, {required String fallback}) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Please verify your connection or check if the server is running.';
    }

    final payload = error.response?.data;
    final payloadMessage = _extractMessage(payload);
    if (payloadMessage != null && payloadMessage.isNotEmpty) {
      return _makeUserFriendly(payloadMessage, statusCode);
    }

    if (statusCode == 401) {
      return 'Incorrect email or password. Please verify your credentials and try again.';
    } else if (statusCode == 403) {
      return 'Access denied. Please check your account role.';
    } else if (statusCode == 404) {
      return 'Requested account was not found.';
    } else if (statusCode == 409) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (statusCode == 429) {
      return 'Too many attempts. Please wait a few moments before trying again.';
    } else if (statusCode != null && statusCode >= 500) {
      return 'Server is currently experiencing an issue. Please try again shortly.';
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return _makeUserFriendly(error.message!, statusCode);
    }

    return fallback;
  }

  String _makeUserFriendly(String raw, int? statusCode) {
    final lower = raw.toLowerCase();

    if (lower.contains('invalid email or password') ||
        lower.contains('invalid credentials') ||
        lower.contains('password is incorrect') ||
        lower.contains('wrong password') ||
        statusCode == 401) {
      return 'Incorrect email or password. Please double-check your credentials and try again.';
    }

    if (lower.contains('not registered as a user') || lower.contains('driver login')) {
      return 'This account is registered as a driver. Please use the Driver application.';
    }

    if (lower.contains('not registered as a driver') || lower.contains('passenger login')) {
      return 'This account is registered as a passenger. Please use passenger login.';
    }

    if (lower.contains('email already exists') || lower.contains('duplicate')) {
      return 'An account with this email address already exists. Please sign in instead.';
    }

    if (lower.contains('passwords do not match')) {
      return 'Passwords do not match. Please ensure both fields are identical.';
    }

    if (lower.contains('password must be between') || lower.contains('at least 8 characters')) {
      return 'Password must be at least 8 characters long.';
    }

    if (lower.contains('invalid email') || lower.contains('valid email address')) {
      return 'Please enter a valid email address (e.g. name@example.com).';
    }

    if (lower.contains('deactivated') || lower.contains('inactive')) {
      return 'This account is deactivated. Please contact support for assistance.';
    }

    if (lower.contains('verification code or token is invalid') || lower.contains('expired')) {
      return 'The verification code is invalid or has expired. Please request a new code.';
    }

    if (lower.contains('user not found')) {
      return 'No account was found with this email address.';
    }

    return raw;
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
