import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transist_tracker/services/auth_service.dart';
import 'package:transist_tracker/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  FlutterSecureStorage.setMockInitialValues({});

  group('AuthService Integration against backend API', () {
    late AuthService authService;
    late Dio dio;

    final testEmail = 'user_test_${DateTime.now().millisecondsSinceEpoch}@transit.lk';
    const testPassword = 'Password123!';
    const newPassword = 'NewPassword123!';

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:3000/api/v1/auth',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      authService = AuthService(
        secureStorageService: SecureStorageService(),
        onUnauthorized: () {},
        dio: dio,
      );
    });

    test('1. User Signup creates account and returns valid token and user', () async {
      final res = await authService.signup(
        name: 'Test Passenger',
        email: testEmail,
        password: testPassword,
        passwordConfirm: testPassword,
        phone: '0712345678',
      );

      expect(res.token, isNotEmpty);
      expect(res.user, isNotNull);
      expect(res.user?.email.toLowerCase(), testEmail.toLowerCase());
      expect(res.user?.name, 'Test Passenger');
      expect(res.user?.role, 'user');
    });

    test('2. User Login authenticates passenger and returns token and user', () async {
      final res = await authService.login(
        email: testEmail,
        password: testPassword,
        rememberMe: true,
      );

      expect(res.token, isNotEmpty);
      expect(res.user, isNotNull);
      expect(res.user?.email.toLowerCase(), testEmail.toLowerCase());
      expect(res.user?.role, 'user');
    });

    test('3. Forgot Password requests 6-digit verification code', () async {
      final res = await authService.forgotPassword(email: testEmail);

      expect(res.message, isNotEmpty);
      expect(res.email?.toLowerCase(), testEmail.toLowerCase());
      expect(res.resetCode, isNotNull);
      expect(res.resetCode?.length, 6);
    });

    test('4. Reset Password successfully updates password with code', () async {
      // Step A: Request forgot password code
      final forgotRes = await authService.forgotPassword(email: testEmail);
      final code = forgotRes.resetCode!;

      // Step B: Reset password
      final resetRes = await authService.resetPassword(
        email: testEmail,
        code: code,
        newPassword: newPassword,
        passwordConfirm: newPassword,
      );

      expect(resetRes.token, isNotEmpty);
      expect(resetRes.user, isNotNull);

      // Step C: Verify user can now log in with the new password
      final loginWithNewPass = await authService.login(
        email: testEmail,
        password: newPassword,
      );
      expect(loginWithNewPass.token, isNotEmpty);
    });

    test('5. Google Login authenticates user and returns valid token and profile', () async {
      final googleTestEmail = 'google_user_${DateTime.now().millisecondsSinceEpoch}@gmail.com';
      final res = await authService.loginWithGoogle(
        email: googleTestEmail,
        name: 'Google Passenger',
        googleId: 'google_uid_987654321',
        profileImage: 'https://example.com/avatar.jpg',
      );

      expect(res.token, isNotEmpty);
      expect(res.user, isNotNull);
      expect(res.user?.email.toLowerCase(), googleTestEmail.toLowerCase());
      expect(res.user?.name, 'Google Passenger');
      expect(res.user?.role, 'user');
    });

    test('6. Login with incorrect password throws 401 DioException', () async {
      expect(
        () => authService.login(
          email: testEmail,
          password: 'WrongPassword123!',
        ),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        )),
      );
    });
  });
}
