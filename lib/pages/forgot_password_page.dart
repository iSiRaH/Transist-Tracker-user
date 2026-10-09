import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/providers/auth_provider.dart';
import 'package:transist_tracker/utils/colors.dart';
import 'package:transist_tracker/widgets/reusable/login_page/input_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCodeSent = false;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRequestCode() async {
    setState(() => _localError = null);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _localError = 'Please enter your email address');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _localError = 'Please enter a valid email address');
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(email: email);

    if (success && mounted) {
      setState(() {
        _isCodeSent = true;
        final devCode = ref.read(authProvider).pendingResetCode;
        if (devCode != null && devCode.isNotEmpty) {
          _codeController.text = devCode;
        }
      });
    }
  }

  void _handleResetPassword() async {
    setState(() => _localError = null);
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (code.isEmpty) {
      setState(() => _localError = 'Please enter the 6-digit verification code');
      return;
    }
    if (newPassword.isEmpty) {
      setState(() => _localError = 'Please enter your new password');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => _localError = 'Password must be at least 8 characters long');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _localError = 'Passwords do not match');
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
          passwordConfirm: confirmPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final activeError = _localError ?? authState.errorMessage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainBlack, size: 20),
          onPressed: () {
            ref.read(authProvider.notifier).showLogin();
          },
        ),
        title: Text(
          "Back to Login",
          style: TextStyle(
            color: mainBlack,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                _isCodeSent ? "Reset Password" : "Forgot Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: mainBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isCodeSent
                    ? "Enter the 6-digit code sent to ${_emailController.text} and create a new password."
                    : "Enter your registered email address to receive a 6-digit verification code.",
                style: TextStyle(
                  fontSize: 14,
                  color: subYellow,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Dev Code Banner (when backend returns code in development)
              if (authState.pendingResetCode != null &&
                  authState.pendingResetCode!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Development Code: ${authState.pendingResetCode}",
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _codeController.text = authState.pendingResetCode!;
                        },
                        child: const Text("Use Code", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],

              if (!_isCodeSent) ...[
                // Step 1: Request Code
                InputField(
                  labelName: "Email Address",
                  hintText: "hello@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: authState.isSubmitting ? null : _handleRequestCode,
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: mainBlack,
                              ),
                            )
                          : Text(
                              "Send Verification Code",
                              style: TextStyle(
                                color: mainBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ] else ...[
                // Step 2: Reset Password Form
                InputField(
                  labelName: "6-Digit Verification Code",
                  hintText: "123456",
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                InputField(
                  labelName: "New Password",
                  hintText: "At least 8 characters",
                  controller: _newPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                InputField(
                  labelName: "Confirm New Password",
                  hintText: "Repeat new password",
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: authState.isSubmitting ? null : _handleResetPassword,
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: mainBlack,
                              ),
                            )
                          : Text(
                              "Reset & Go to Dashboard",
                              style: TextStyle(
                                color: mainBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: authState.isSubmitting
                        ? null
                        : () {
                            setState(() => _isCodeSent = false);
                          },
                    child: Text(
                      "Change email or resend code",
                      style: TextStyle(
                        color: mainYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              if (activeError != null && activeError.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activeError,
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

              if (authState.successMessage != null &&
                  authState.successMessage!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.successMessage!,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
