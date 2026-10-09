import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/providers/auth_provider.dart';
import 'package:transist_tracker/utils/colors.dart';
import 'package:transist_tracker/widgets/reusable/login_page/input_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _localError = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _localError = 'Please enter your email address');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _localError = 'Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _localError = 'Please enter your password');
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
          rememberMe: _rememberMe,
        );

    if (success && mounted) {
      // If LoginPage was pushed via Navigator, pop until root to show Dashboard
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _localError = null);
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayError = _localError ?? authState.errorMessage;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: mainBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Welcome back to Transit Tracker",
                style: TextStyle(
                  fontSize: 16,
                  color: subYellow,
                ),
              ),
              const SizedBox(height: 30),
              InputField(
                labelName: "Email Address",
                hintText: "hello@example.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              InputField(
                labelName: "Password",
                hintText: "...............",
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: mainYellow,
                          checkColor: mainBlack,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Keep me signed in",
                        style: TextStyle(
                          color: inputTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).showForgotPassword();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: mainYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: authState.isSubmitting ? null : _handleLogin,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainYellow,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Center(
                    child: authState.isSubmitting
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: mainBlack,
                            ),
                          )
                        : Text(
                            "Login",
                            style: TextStyle(
                              color: mainBlack,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              if (displayError != null && displayError.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayError,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: dividerColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "or sign in with",
                    style: TextStyle(
                      color: inputTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: dividerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: authState.isSubmitting ? null : _handleGoogleLogin,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainAsh,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/google_icon.png",
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: mainBlack,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).showSignup();
                },
                child: Text(
                  "Don't have an account? Create one",
                  style: TextStyle(
                    color: mainYellow,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
