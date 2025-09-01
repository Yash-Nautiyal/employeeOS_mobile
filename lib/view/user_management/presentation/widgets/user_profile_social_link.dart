import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserProfileSocialLink extends StatelessWidget {
  final ThemeData theme;
  const UserProfileSocialLink({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Social Links",
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.disabledColor),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgPicture.asset(
                "assets/icons/social/ic-facebbook.svg",
                width: 25,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(
                  "facebook.com/yash",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/social/ic-instagram.svg",
                width: 25,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(
                  "facebook.com/yash",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/social/ic-linkedin.svg",
                width: 25,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(
                  "facebook.com/yash",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/social/ic-twitter.svg",
                width: 25,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(
                  "facebook.com/yash",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
