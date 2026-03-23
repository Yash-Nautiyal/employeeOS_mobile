import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAccountSocialLinks extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController facebookController;
  final TextEditingController instagramController;
  final TextEditingController xController;
  final TextEditingController linkedinController;
  const UserAccountSocialLinks(
      {super.key,
      required this.theme,
      required this.facebookController,
      required this.instagramController,
      required this.xController,
      required this.linkedinController});

  @override
  Widget build(BuildContext context) {
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
                  controller: facebookController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: 'https://facebook.com/username',
                  labelText: 'Facebook',
                  prefix: SvgPicture.asset(
                    'assets/icons/social/ic-facebbook.svg',
                    width: 30,
                  ),
                  alwaysFloatingLabel: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  controller: instagramController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: 'https://instagram.com/username',
                  labelText: 'Instagram',
                  prefix: SvgPicture.asset(
                    'assets/icons/social/ic-instagram.svg',
                    width: 30,
                  ),
                  alwaysFloatingLabel: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  controller: linkedinController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: 'https://linkedin.com.in/username',
                  labelText: 'Linkedin',
                  prefix: SvgPicture.asset(
                    'assets/icons/social/ic-linkedin.svg',
                    width: 30,
                  ),
                  alwaysFloatingLabel: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  controller: xController,
                  keyboardType: TextInputType.text,
                  theme: theme,
                  onchange: () {},
                  hintText: 'https://twitter.com/username',
                  labelText: 'Twitter',
                  prefix: SvgPicture.asset(
                    'assets/icons/social/ic-twitter.svg',
                    width: 30,
                    color: theme.colorScheme.onSurface,
                  ),
                  alwaysFloatingLabel: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextButton(
                  onClick: () {},
                  backgroundColor: theme.colorScheme.onSurface,
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
