import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  // Allows backend host override at runtime:
  // flutter run --dart-define=AUTH_BASE_URL=http://192.168.1.50:3000
  static const String _authBaseUrlOverride =
      String.fromEnvironment('AUTH_BASE_URL', defaultValue: '');

  static const String loginPath = String.fromEnvironment(
    'AUTH_LOGIN_PATH',
    defaultValue: '/login',
  );

  static const String signupPath = String.fromEnvironment(
    'AUTH_SIGNUP_PATH',
    defaultValue: '/signup',
  );

  static const String mePath = String.fromEnvironment(
    'AUTH_ME_PATH',
    defaultValue: '/me',
  );

  static String get _host {
    if (_authBaseUrlOverride.isNotEmpty) {
      return _authBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static String get authBaseUrl => '$_host/api/v1/auth';
}
