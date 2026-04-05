import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/index.dart' show UserRole;

class UserProfileRole extends StatelessWidget {
  final ThemeData theme;
  final String role;
  final Map<String, dynamic> socialLinks;
  const UserProfileRole(
      {super.key,
      required this.theme,
      required this.role,
      required this.socialLinks});

  @override
  Widget build(BuildContext context) {
    final userRole = UserRole.fromString(role);
    final socialLinks = this.socialLinks;
    final facebookLink = socialLinks['facebook'];
    final instagramLink = socialLinks['instagram'];
    final linkedinLink = socialLinks['linkedin'];
    final twitterLink = socialLinks['twitter'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.dividerColor,
            child: const Icon(
              Icons.person,
              size: 30,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            userRole.value.toUpperCase(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  if (facebookLink != null) {
                    launchUrl(Uri.parse(facebookLink),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: SvgPicture.asset(
                  "assets/icons/social/ic-facebbook.svg",
                  width: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (instagramLink != null) {
                    launchUrl(Uri.parse(instagramLink),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: SvgPicture.asset(
                  "assets/icons/social/ic-instagram.svg",
                  width: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (linkedinLink != null) {
                    launchUrl(Uri.parse(linkedinLink),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: SvgPicture.asset(
                  "assets/icons/social/ic-linkedin.svg",
                  width: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (twitterLink != null) {
                    launchUrl(Uri.parse(twitterLink),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: SvgPicture.asset(
                  "assets/icons/social/ic-twitter.svg",
                  width: 20,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
