import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserProfileRole extends StatelessWidget {
  final ThemeData theme;
  const UserProfileRole({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
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
            'ADMIN',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset(
                "assets/icons/social/ic-facebbook.svg",
                width: 20,
              ),
              SvgPicture.asset(
                "assets/icons/social/ic-instagram.svg",
                width: 20,
              ),
              SvgPicture.asset(
                "assets/icons/social/ic-linkedin.svg",
                width: 20,
              ),
              SvgPicture.asset(
                "assets/icons/social/ic-twitter.svg",
                width: 20,
                color: theme.colorScheme.tertiary,
              ),
            ],
          )
        ],
      ),
    );
  }
}
