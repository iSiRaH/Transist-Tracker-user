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
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 35,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create an  account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainBlack,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Welcome back to the app",
                  style: TextStyle(
                    fontSize: 16,
                    color: subYellow,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                InputField(
                  labelName: "Name",
                  hintText: "John Doe",
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 15,
                ),
                InputField(
                  labelName: "Email Address",
                  hintText: "hello@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 15,
                ),
                InputField(
                  labelName: "Password",
                  hintText: "...............",
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(
                        "By continuing, you agree to our terms of service. ",
                        softWrap: true,
                        style: TextStyle(
                          color: inputTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: authState.isSubmitting
                      ? null
                      : () {
                          ref.read(authProvider.notifier).signup(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainYellow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
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
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                if (authState.errorMessage != null) ...[
                  SizedBox(height: 12),
                  Text(
                    authState.errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: dividerColor,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "or sign up with",
                      style: TextStyle(
                        color: inputTextColor,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: dividerColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainAsh,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/google_icon.png",
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: mainBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: mainYellow.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "Sign in here",
                        style: TextStyle(
                          color: mainYellow,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ref.read(authProvider.notifier).showLogin();
                          },
                      ),
                    ],
                  ),
                ),
                // Text(
                //   "Already have an account? Sign in here",
                //   style: TextStyle(
                //     color: mainYellow,
                //     fontWeight: FontWeight.w500,
                //     fontSize: 16,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
