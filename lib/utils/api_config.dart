import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  const ApiConfig._();

  static String? _getEnv(String key) {
    if (dotenv.isInitialized) {
      final value = dotenv.maybeGet(key);
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  // Priority:
  // 1. .env file (via flutter_dotenv)
  // 2. --dart-define=AUTH_BASE_URL=... (or --dart-define-from-file=.env)
  // 3. Platform default host
  static String get _authBaseUrlOverride {
    final fromDotenv = _getEnv('AUTH_BASE_URL');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment('AUTH_BASE_URL', defaultValue: '');
  }

  static String get loginPath {
    final fromDotenv = _getEnv('AUTH_LOGIN_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_LOGIN_PATH',
      defaultValue: '/user/login',
    );
  }

  static String get signupPath {
    final fromDotenv = _getEnv('AUTH_SIGNUP_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_SIGNUP_PATH',
      defaultValue: '/user/signup',
    );
  }

  static String get forgotPasswordPath {
    final fromDotenv = _getEnv('AUTH_FORGOT_PASSWORD_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_FORGOT_PASSWORD_PATH',
      defaultValue: '/forgot-password',
    );
  }

  static String get resetPasswordPath {
    final fromDotenv = _getEnv('AUTH_RESET_PASSWORD_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_RESET_PASSWORD_PATH',
      defaultValue: '/reset-password',
    );
  }

  static String get mePath {
    final fromDotenv = _getEnv('AUTH_ME_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_ME_PATH',
      defaultValue: '/me',
    );
  }

  static String get googleLoginPath {
    final fromDotenv = _getEnv('AUTH_GOOGLE_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_GOOGLE_PATH',
      defaultValue: '/user/google',
    );
  }

  static String? get googleClientId {
    final fromDotenv = _getEnv('GOOGLE_CLIENT_ID');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    const fromDefine = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
    return fromDefine.isNotEmpty ? fromDefine : null;
  }

  static String? get googleServerClientId {
    final fromDotenv = _getEnv('GOOGLE_SERVER_CLIENT_ID');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    const fromDefine = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
    return fromDefine.isNotEmpty ? fromDefine : null;
  }

  static String? get googleIosClientId {
    final fromDotenv = _getEnv('GOOGLE_IOS_CLIENT_ID');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    const fromDefine = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID', defaultValue: '');
    return fromDefine.isNotEmpty ? fromDefine : null;
  }

  static String get host {
    final override = _authBaseUrlOverride;
    if (override.isNotEmpty) {
      // If running on desktop/web and the override was set to an emulator IP like 10.0.2.2,
      // fallback to localhost:3000 to prevent connection timeouts.
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows)) {
        if (override.contains('10.0.2.2')) {
          return override.replaceAll('10.0.2.2', '127.0.0.1');
        }
      }

      // If running on Android and override contains localhost/127.0.0.1,
      // map to 10.0.2.2 for emulator compatibility
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (override.contains('localhost')) {
          return override.replaceAll('localhost', '10.0.2.2');
        }
        if (override.contains('127.0.0.1')) {
          return override.replaceAll('127.0.0.1', '10.0.2.2');
        }
      }

      return override;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  static String get authBaseUrl {
    final baseUrl = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
    if (baseUrl.contains('/api/v1/auth')) {
      return baseUrl;
    }
    return '$baseUrl/api/v1/auth';
  }
}
