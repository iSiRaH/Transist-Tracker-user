import 'package:dio/dio.dart';
import 'package:transist_tracker/services/secure_storage_service.dart';
import 'package:transist_tracker/utils/api_config.dart';

typedef UnauthorizedCallback = void Function();

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
        _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.authBaseUrl)) {
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

  Future<String> login(
      {required String email, required String password}) async {
    final response = await _dio.post(
      ApiConfig.loginPath,
      data: {
        'email': email,
        'password': password,
      },
    );

    return _extractToken(response.data);
  }

  Future<String> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConfig.signupPath,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return _extractToken(response.data);
  }

  Future<void> saveSession(String token) async {
    await _secureStorageService.saveToken(token);
  }

  Future<String?> getSavedToken() async {
    return _secureStorageService.readToken();
  }

  Future<void> clearSession() async {
    await _secureStorageService.clearToken();
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _dio.get(ApiConfig.mePath);
    final payload = response.data;

    if (payload is Map<String, dynamic>) {
      final nestedUser = payload['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      final nestedData = payload['data'];
      if (nestedData is Map<String, dynamic>) {
        final dataUser = nestedData['user'];
        if (dataUser is Map<String, dynamic>) {
          return dataUser;
        }

        return nestedData;
      }

      return payload;
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
}
