import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class UserAccountSecurity extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  const UserAccountSecurity(
      {super.key,
      required this.theme,
      required this.oldPasswordController,
      required this.newPasswordController,
      required this.confirmPasswordController});

  @override
  Widget build(BuildContext context) {
    const isOldPasswordVisible = false;
    const isNewPasswordVisible = false;
    const isConfirmPasswordVisible = false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.shadowColor),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextfield(
                  controller: oldPasswordController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: '',
                  labelText: 'Old Password',
                  isPasswordVisible: isOldPasswordVisible,
                  onClickPasswordVisisble: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  controller: newPasswordController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: '',
                  labelText: 'New Password',
                  isPasswordVisible: isNewPasswordVisible,
                  onClickPasswordVisisble: () {},
                  helper: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: theme.disabledColor,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Password must be minimum 6+",
                        style: theme.textTheme.bodySmall,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: '',
                  labelText: 'Confirm Password',
                  isPasswordVisible: isConfirmPasswordVisible,
                  onClickPasswordVisisble: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextButton(
                  onClick: () {},
                  backgroundColor: theme.colorScheme.tertiary,
                  child: Text(
                    "Save Changes",
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.scaffoldBackgroundColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
