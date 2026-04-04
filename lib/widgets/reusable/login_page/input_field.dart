import 'package:flutter/material.dart';
import 'package:transist_tracker/utils/colors.dart';

class InputField extends StatelessWidget {
  final String labelName;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  const InputField(
      {super.key,
      required this.labelName,
      required this.hintText,
      this.controller,
      this.obscureText = false,
      this.keyboardType = TextInputType.text,
      this.textInputAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelName,
          style: TextStyle(
            fontSize: 12,
            color: inputTextColor,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: mainAsh,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: subYellow,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: subYellow,
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: subYellow.withValues(alpha: 0.3),
                width: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
