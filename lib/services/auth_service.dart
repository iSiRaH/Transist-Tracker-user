import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:transist_tracker/models/User.dart';
import 'package:transist_tracker/services/secure_storage_service.dart';
import 'package:transist_tracker/utils/api_config.dart';

typedef UnauthorizedCallback = void Function();

class AuthResponse {
  final String token;
  final User? user;
  final String? message;

  const AuthResponse({
    required this.token,
    this.user,
    this.message,
  });
}

class ForgotPasswordResponse {
  final String message;
  final String? email;
  final String? resetCode;

  const ForgotPasswordResponse({
    required this.message,
    this.email,
    this.resetCode,
  });
}

class AuthService {
  final Dio _dio;
  final SecureStorageService _secureStorageService;
  final UnauthorizedCallback _onUnauthorized;

  AuthService({
    required SecureStorageService secureStorageService,
    required UnauthorizedCallback onUnauthorized,
    Dio? dio,
  })  : _secureStorageService = secureStorageService,
        _onUnauthorized = onUnauthorized,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.authBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorageService.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            _onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await _dio.post(
      ApiConfig.loginPath,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'rememberMe': rememberMe,
      },
    );

    final token = _extractToken(response.data);
    final user = _extractUser(response.data);
    final message = _extractMessage(response.data);

    return AuthResponse(
      token: token,
      user: user,
      message: message,
    );
  }

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    bool rememberMe = false,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'passwordConfirm': passwordConfirm,
      'role': 'user',
      'rememberMe': rememberMe,
    };

    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    }

    final response = await _dio.post(
      ApiConfig.signupPath,
      data: payload,
    );

    final token = _extractToken(response.data);
    final user = _extractUser(response.data);
    final message = _extractMessage(response.data);

    return AuthResponse(
      token: token,
      user: user,
      message: message,
    );
  }

  Future<AuthResponse> loginWithGoogle({
    String? idToken,
    String? email,
    String? name,
    String? googleId,
    String? profileImage,
    bool rememberMe = true,
  }) async {
    final payload = <String, dynamic>{
      'rememberMe': rememberMe,
    };
    if (idToken != null && idToken.isNotEmpty) payload['idToken'] = idToken;
    if (email != null && email.isNotEmpty) payload['email'] = email;
    if (name != null && name.isNotEmpty) payload['name'] = name;
    if (googleId != null && googleId.isNotEmpty) payload['googleId'] = googleId;
    if (profileImage != null && profileImage.isNotEmpty) {
      payload['profileImage'] = profileImage;
    }

    final response = await _dio.post(
      ApiConfig.googleLoginPath,
      data: payload,
    );

    final token = _extractToken(response.data);
    final user = _extractUser(response.data);
    final message = _extractMessage(response.data);

    return AuthResponse(
      token: token,
      user: user,
      message: message,
    );
  }

  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    final response = await _dio.post(
      ApiConfig.forgotPasswordPath,
      data: {
        'email': email.trim().toLowerCase(),
      },
    );

    final payload = response.data;
    String message = 'Verification code has been sent to your email.';
    String? resolvedEmail = email;
    String? resetCode;

    if (payload is Map<String, dynamic>) {
      if (payload['message'] is String) {
        message = payload['message'];
      }
      if (payload['resetCode'] != null) {
        resetCode = payload['resetCode'].toString();
      }
      final data = payload['data'];
      if (data is Map<String, dynamic> && data['email'] != null) {
        resolvedEmail = data['email'].toString();
      }
    }

    return ForgotPasswordResponse(
      message: message,
      email: resolvedEmail,
      resetCode: resetCode,
    );
  }

  Future<AuthResponse> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirm,
  }) async {
    final response = await _dio.patch(
      ApiConfig.resetPasswordPath,
      data: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
        'passwordConfirm': passwordConfirm,
      },
    );

    final token = _extractToken(response.data);
    final user = _extractUser(response.data);
    final message = _extractMessage(response.data);

    return AuthResponse(
      token: token,
      user: user,
      message: message,
    );
  }

  Future<void> saveSession(String token, [User? user]) async {
    await _secureStorageService.saveToken(token);
    if (user != null) {
      await _secureStorageService.saveUserJson(jsonEncode(user.toJson()));
    }
  }

  Future<String?> getSavedToken() async {
    return _secureStorageService.readToken();
  }

  Future<User?> getSavedUser() async {
    final jsonStr = await _secureStorageService.readUserJson();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      if (map is Map<String, dynamic>) {
        return User.fromJson(map);
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearSession() async {
    await _secureStorageService.clearAll();
  }

  Future<User> fetchCurrentUser() async {
    final response = await _dio.get(ApiConfig.mePath);
    final payload = response.data;

    final user = _extractUser(payload);
    if (user != null) {
      return user;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiConfig.mePath),
      message: 'Invalid user response payload',
      type: DioExceptionType.badResponse,
    );
  }

  String _extractToken(dynamic payload) {
    final token = _findToken(payload);
    if (token != null) {
      return token;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ''),
      message: 'Token not found in response payload',
      type: DioExceptionType.badResponse,
    );
  }

  String? _findToken(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    const tokenKeys = <String>['token', 'accessToken', 'jwt'];

    for (final key in tokenKeys) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final nestedCandidates = <dynamic>[
      payload['data'],
      payload['result'],
      payload['user'],
    ];

    for (final candidate in nestedCandidates) {
      final nestedToken = _findToken(candidate);
      if (nestedToken != null) {
        return nestedToken;
      }
    }

    return null;
  }

  User? _extractUser(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;

    if (payload['user'] is Map<String, dynamic>) {
      return User.fromJson(payload['user'] as Map<String, dynamic>);
    }

    if (payload['data'] is Map<String, dynamic>) {
      final dataMap = payload['data'] as Map<String, dynamic>;
      if (dataMap['user'] is Map<String, dynamic>) {
        return User.fromJson(dataMap['user'] as Map<String, dynamic>);
      }
      if (dataMap['id'] != null || dataMap['_id'] != null) {
        return User.fromJson(dataMap);
      }
    }

    return null;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['message'] is String) {
      return payload['message'] as String;
    }
    return null;
  }
}
