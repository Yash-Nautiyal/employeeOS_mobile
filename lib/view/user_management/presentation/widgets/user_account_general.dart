import 'package:employeeos/core/common/components/custom_dropdown.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAccountGeneral extends StatelessWidget {
  final ThemeData theme;
  final bool isPublicProfile;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController stateController;
  final TextEditingController cityController;
  final TextEditingController zipController;
  final TextEditingController aboutController;
  final String selectedCountry;
  final Function(bool) onPublicProfileChanged;
  const UserAccountGeneral(
      {super.key,
      required this.theme,
      required this.isPublicProfile,
      required this.nameController,
      required this.emailController,
      required this.phoneController,
      required this.addressController,
      required this.stateController,
      required this.cityController,
      required this.zipController,
      required this.aboutController,
      required this.selectedCountry,
      required this.onPublicProfileChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Profile Photo Section
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
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      child: Icon(
                        Icons.person,
                        size: 60,
                      ),
                    ),
                    CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.shadowColor.withOpacity(.3),
                        child: Column(
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
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )),
                  ],
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
          // Form Fields Section
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
                _buildTextField('Name', nameController, theme),
                const SizedBox(height: 25),
                _buildTextField('Email', emailController, theme),
                const SizedBox(height: 25),
                _buildTextField('Phone number', phoneController, theme),
                const SizedBox(height: 25),
                _buildTextField('Address', addressController, theme),
                const SizedBox(height: 25),
                _buildDropdownField('Country', selectedCountry, theme),
                const SizedBox(height: 25),
                _buildTextField('State/region', stateController, theme),
                const SizedBox(height: 25),
                _buildTextField('City', cityController, theme),
                const SizedBox(height: 25),
                _buildTextField('Zip/code', zipController, theme),
                const SizedBox(height: 25),
                _buildTextField('About', aboutController, theme, maxLines: 4),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextButton(
                    onClick: () {},
                    backgroundColor: theme.colorScheme.tertiary,
                    child: Text(
                      "Save Changes",
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.scaffoldBackgroundColor),
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
      {int maxLines = 1}) {
    return CustomTextfield(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      theme: theme,
      hintText: 'Enter your $label',
      labelText: label,
      onchange: (value) {},
    );
  }

  Widget _buildDropdownField(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
            theme: theme,
            onChange: () {},
            label: label,
            items: const [
              DropdownMenuItem(value: 'Country 1', child: Text('Country 1')),
            ]),
      ],
    );
  }
}
