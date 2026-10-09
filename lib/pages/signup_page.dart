import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/providers/auth_provider.dart';
import 'package:transist_tracker/utils/colors.dart';
import 'package:transist_tracker/widgets/reusable/login_page/input_field.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = true;
  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    setState(() => _localError = null);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _localError = 'Please enter your full name');
      return;
    }
    if (email.isEmpty) {
      setState(() => _localError = 'Please enter your email address');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _localError = 'Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _localError = 'Please enter a password');
      return;
    }
    if (password.length < 8) {
      setState(() => _localError = 'Password must be at least 8 characters long');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _localError = 'Passwords do not match');
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _localError = 'Please agree to the terms of service to continue');
      return;
    }

    await ref.read(authProvider.notifier).signup(
          name: name,
          email: email,
          password: password,
          passwordConfirm: confirmPassword,
          phone: phone.isNotEmpty ? phone : null,
        );
  }

  void _handleGoogleLogin() async {
    setState(() => _localError = null);
    await ref.read(authProvider.notifier).loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayError = _localError ?? authState.errorMessage;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: mainBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up to start tracking your transit journey",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subYellow,
                ),
              ),
              const SizedBox(height: 25),
              InputField(
                labelName: "Full Name",
                hintText: "John Doe",
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                labelName: "Email Address",
                hintText: "hello@example.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                labelName: "Phone Number (Optional)",
                hintText: "+94 77 123 4567",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                labelName: "Password",
                hintText: "At least 8 characters",
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                labelName: "Confirm Password",
                hintText: "Repeat password",
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: mainYellow,
                      checkColor: mainBlack,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "By continuing, you agree to our terms of service.",
                      style: TextStyle(
                        color: inputTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: authState.isSubmitting ? null : _handleSignup,
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
                            "Sign up",
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
              const SizedBox(height: 20),
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
                    "or sign up with",
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 30),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: mainBlack.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "Sign in here",
                      style: TextStyle(
                        color: mainYellow,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref.read(authProvider.notifier).showLogin();
                        },
                    ),
                  ],
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
