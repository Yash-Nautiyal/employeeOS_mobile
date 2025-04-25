import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ThemeData theme;
  final Function onchange;
  final TextInputType keyboardType;
  final String? labelText;
  final bool? isPasswordVisible;
  final Function? onClickPasswordVisisble;
  final int? maxLines;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.theme,
    required this.onchange,
    required this.hintText,
    this.onClickPasswordVisisble,
    this.labelText,
    this.isPasswordVisible,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      obscureText: isPasswordVisible != null ? !(isPasswordVisible!) : false,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onchange(value),
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: labelText?.isNotEmpty == true ? labelText : null,
        hintText: hintText,
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
