import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAccountGeneral extends StatelessWidget {
  final ThemeData theme;
  final String? avatarUrl;
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

  const UserAccountGeneral({
    super.key,
    required this.theme,
    required this.avatarUrl,
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
  });

  @override
  Widget build(BuildContext context) {
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
                        backgroundImage:
                            avatarUrl != null && avatarUrl!.isNotEmpty
                                ? NetworkImage(avatarUrl!)
                                : null,
                        child: avatarUrl == null || avatarUrl!.isEmpty
                            ? Text(
                                getInitials(
                                    "${firstNameController.text} ${lastNameController.text}"),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: isUploadingAvatar
                            ? null
                            : () {
                                onAvatarTap();
                              },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.shadowColor.withOpacity(.3),
                          child: isUploadingAvatar
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
                                      'Update photo',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                _buildTextField('First Name', firstNameController, theme),
                const SizedBox(height: 25),
                _buildTextField('Last Name', lastNameController, theme),
                const SizedBox(height: 25),
                _buildTextField('Email', emailController, theme,
                    isReadOnly: true),
                const SizedBox(height: 25),
                _buildTextField('Phone number', phoneController, theme),
                const SizedBox(height: 25),
                _buildTextField('Role', roleController, theme,
                    isReadOnly: true),
                const SizedBox(height: 25),
                _buildTextField('Date of Birth', dateOfBirthController, theme),
                const SizedBox(height: 25),
                _buildTextField('Designation', designationController, theme),
                const SizedBox(height: 25),
                _buildTextField(
                    'Date of Joining', dateOfJoiningController, theme),
                const SizedBox(height: 25),
                _buildTextField(
                    'Date of Relieving', dateofRelievingController, theme),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextButton(
                    enabled: saveEnabled && !isSaving,
                    onClick: () {
                      onSave();
                    },
                    backgroundColor: theme.colorScheme.tertiary,
                    child: Text(
                      isSaving ? 'Saving…' : 'Save Changes',
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
