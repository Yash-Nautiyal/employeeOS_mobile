import 'package:employeeos/core/common/components/ui/custom_textbutton.dart';
import 'package:employeeos/core/common/components/ui/custom_textfield.dart';
import 'package:flutter/material.dart';

class UserAccountSecurity extends StatefulWidget {
  final ThemeData theme;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool saveEnabled;
  final bool isSaving;
  final Future<void> Function() onSave;

  const UserAccountSecurity({
    super.key,
    required this.theme,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.saveEnabled,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<UserAccountSecurity> createState() => _UserAccountSecurityState();
}

class _UserAccountSecurityState extends State<UserAccountSecurity> {
  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextfield(
                  controller: widget.oldPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  theme: theme,
                  onchange: (_) {},
                  hintText: 'Enter current password',
                  labelText: 'Current password',
                  isPasswordVisible: _oldVisible,
                  onClickPasswordVisisble: () {
                    setState(() => _oldVisible = !_oldVisible);
                  },
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: widget.newPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  theme: theme,
                  onchange: (_) {},
                  hintText: 'Enter new password',
                  labelText: 'New password',
                  isPasswordVisible: _newVisible,
                  onClickPasswordVisisble: () {
                    setState(() => _newVisible = !_newVisible);
                  },
                  helper: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: theme.disabledColor,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Password must be at least 6 characters',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: widget.confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  theme: theme,
                  onchange: (_) {},
                  hintText: 'Confirm new password',
                  labelText: 'Confirm password',
                  isPasswordVisible: _confirmVisible,
                  onClickPasswordVisisble: () {
                    setState(() => _confirmVisible = !_confirmVisible);
                  },
                ),
                const SizedBox(height: 20),
                CustomTextButton(
                  enabled: widget.saveEnabled && !widget.isSaving,
                  onClick: () {
                    widget.onSave();
                  },
                  backgroundColor: theme.colorScheme.tertiary,
                  child: Text(
                    widget.isSaving ? 'Updating…' : 'Update password',
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
