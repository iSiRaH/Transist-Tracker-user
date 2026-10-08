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
      defaultValue: '/login',
    );
  }

  static String get signupPath {
    final fromDotenv = _getEnv('AUTH_SIGNUP_PATH');
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'AUTH_SIGNUP_PATH',
      defaultValue: '/signup',
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

  static String get _host {
    if (_authBaseUrlOverride.isNotEmpty) {
      return _authBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.0.77:3000';
    }

    return 'http://localhost:3000';
  }

  static String get authBaseUrl => '$_host/api/v1/auth';
}
