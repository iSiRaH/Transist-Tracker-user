import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/pages/home_page.dart';
import 'package:transist_tracker/pages/login_page.dart';
import 'package:transist_tracker/pages/onboarding_page.dart';
import 'package:transist_tracker/pages/signup_page.dart';
import 'package:transist_tracker/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Info: Could not load .env file ($error). Using default configuration.');
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Transist Tracker",
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authState.hasCompletedOnboarding) {
      return const OnboardingPage();
    }

    if (authState.authStatus == AuthStatus.authenticated) {
      return const HomePage();
    }

    if (authState.authScreen == AuthScreen.signup) {
      return const SignupPage();
    }

    return const LoginPage();
  }
}