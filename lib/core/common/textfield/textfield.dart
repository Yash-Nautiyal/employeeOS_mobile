import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController passwordController;
  final String hintText;
  final String labelText;
  final ThemeData theme;
  final Function onchange;
  final TextInputType keyboardType;
  final bool? isPasswordVisible;
  final Function? onClickPasswordVisisble;

  const CustomTextfield(
      {super.key,
      required this.passwordController,
      this.isPasswordVisible,
      required this.theme,
      this.onClickPasswordVisisble,
      required this.hintText,
      required this.labelText,
      required this.keyboardType,
      required this.onchange});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: passwordController,
      obscureText: !(isPasswordVisible ?? false),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onchange(value),
      decoration: InputDecoration(
        labelText: hintText,
        hintText: labelText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        suffixIcon: isPasswordVisible != null
            ? IconButton(
                icon: Icon(
                  (isPasswordVisible ?? false)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  if (onClickPasswordVisisble != null) {
                    onClickPasswordVisisble!(); // Invoke the function
                  }
                },
              )
            : null,
      ),
    );
  }
}
