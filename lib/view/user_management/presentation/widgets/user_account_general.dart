import 'dart:typed_data';

import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAccountGeneral extends StatefulWidget {
  final ThemeData theme;
  final String? avatarUrl;
  final Uint8List? localAvatarBytes;
  final TextEditingController roleController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController dateOfBirthController;
  final TextEditingController designationController;
  final TextEditingController dateOfJoiningController;
  final TextEditingController dateofRelievingController;
  final bool saveEnabled;
  final bool isSaving;
  final bool isUploadingAvatar;
  final Future<void> Function() onSave;
  final Future<void> Function() onAvatarTap;

  final bool isCreateUserFlow;
  final String primaryButtonLabel;
  final String primaryButtonLoadingLabel;
  final String avatarActionLabel;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final String? roleDropdownValue;
  final ValueChanged<dynamic>? onRoleChanged;

  const UserAccountGeneral({
    super.key,
    required this.theme,
    required this.avatarUrl,
    this.localAvatarBytes,
    required this.roleController,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.dateOfBirthController,
    required this.designationController,
    required this.dateOfJoiningController,
    required this.dateofRelievingController,
    required this.saveEnabled,
    required this.isSaving,
    required this.isUploadingAvatar,
    required this.onSave,
    required this.onAvatarTap,
    this.isCreateUserFlow = false,
    this.primaryButtonLabel = 'Save Changes',
    this.primaryButtonLoadingLabel = 'Saving…',
    this.avatarActionLabel = 'Update photo',
    this.passwordController,
    this.confirmPasswordController,
    this.roleDropdownValue,
    this.onRoleChanged,
  });

  @override
  State<UserAccountGeneral> createState() => _UserAccountGeneralState();
}

class _UserAccountGeneralState extends State<UserAccountGeneral> {
  bool _pwVisible = false;
  bool _pwConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final theme = w.theme;
    final hasLocalAvatar =
        w.localAvatarBytes != null && w.localAvatarBytes!.isNotEmpty;
    final hasRemoteAvatar =
        w.avatarUrl != null && w.avatarUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            width: double.maxFinite,
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
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: hasLocalAvatar
                            ? MemoryImage(w.localAvatarBytes!)
                            : (hasRemoteAvatar
                                ? NetworkImage(w.avatarUrl!)
                                : null),
                        child: !hasLocalAvatar && !hasRemoteAvatar
                            ? Text(
                                getInitials(
                                    "${w.firstNameController.text} ${w.lastNameController.text}"),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: w.isUploadingAvatar
                            ? null
                            : () {
                                w.onAvatarTap();
                              },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.shadowColor.withOpacity(.3),
                          child: w.isUploadingAvatar
                              ? const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/common/solid/ic-solar_camera-add-bold.svg',
                                      width: 30,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      w.avatarActionLabel,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Allowed *.jpeg, *.jpg, *.png, *.gif',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Max size of 3.1 MB',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField('First Name', w.firstNameController, theme),
                const SizedBox(height: 25),
                _buildTextField('Last Name', w.lastNameController, theme),
                const SizedBox(height: 25),
                _buildTextField('Email', w.emailController, theme,
                    isReadOnly: !w.isCreateUserFlow),
                if (w.isCreateUserFlow &&
                    w.passwordController != null &&
                    w.confirmPasswordController != null) ...[
                  const SizedBox(height: 25),
                  CustomTextfield(
                    controller: w.passwordController!,
                    keyboardType: TextInputType.visiblePassword,
                    theme: theme,
                    hintText: 'Temporary password (min 6 characters)',
                    labelText: 'Password',
                    onchange: (_) {},
                    isPasswordVisible: _pwVisible,
                    onClickPasswordVisisble: () {
                      setState(() => _pwVisible = !_pwVisible);
                    },
                  ),
                  const SizedBox(height: 25),
                  CustomTextfield(
                    controller: w.confirmPasswordController!,
                    keyboardType: TextInputType.visiblePassword,
                    theme: theme,
                    hintText: 'Confirm password',
                    labelText: 'Confirm password',
                    onchange: (_) {},
                    isPasswordVisible: _pwConfirmVisible,
                    onClickPasswordVisisble: () {
                      setState(() => _pwConfirmVisible = !_pwConfirmVisible);
                    },
                  ),
                ],
                const SizedBox(height: 25),
                _buildTextField('Phone number', w.phoneController, theme),
                const SizedBox(height: 25),
                if (w.isCreateUserFlow && w.onRoleChanged != null)
                  _buildRoleDropdown(theme, w)
                else
                  _buildTextField('Role', w.roleController, theme,
                      isReadOnly: true),
                const SizedBox(height: 25),
                _buildTextField('Date of Birth', w.dateOfBirthController, theme),
                const SizedBox(height: 25),
                _buildTextField('Designation', w.designationController, theme),
                const SizedBox(height: 25),
                _buildTextField(
                    'Date of Joining', w.dateOfJoiningController, theme),
                const SizedBox(height: 25),
                _buildTextField(
                    'Date of Relieving', w.dateofRelievingController, theme),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextButton(
                    enabled: w.saveEnabled && !w.isSaving,
                    onClick: () {
                      w.onSave();
                    },
                    backgroundColor: theme.colorScheme.tertiary,
                    child: Text(
                      w.isSaving
                          ? w.primaryButtonLoadingLabel
                          : w.primaryButtonLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(ThemeData theme, UserAccountGeneral w) {
    final raw = w.roleDropdownValue?.trim() ?? '';
    final dropdownValue =
        raw.isEmpty ? null : UserRole.fromString(raw).name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          theme: theme,
          value: dropdownValue,
          onChange: (value) {
            w.onRoleChanged?.call(value);
          },
          label: 'Role',
          items: UserRole.values
              .map(
                (e) => DropdownMenuItem(
                  value: e.name,
                  child: Text(_roleMenuLabel(e)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static String _roleMenuLabel(UserRole r) {
    switch (r) {
      case UserRole.hr:
        return 'HR';
      case UserRole.admin:
        return 'Admin';
      case UserRole.employee:
        return 'Employee';
    }
  }

  Widget _buildTextField(
      String label, TextEditingController controller, ThemeData theme,
      {int maxLines = 1, bool isReadOnly = false}) {
    return CustomTextfield(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      theme: theme,
      hintText: 'Enter your $label',
      labelText: label,
      onchange: (value) {},
      readOnly: isReadOnly,
    );
  }
}
