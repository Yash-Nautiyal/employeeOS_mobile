import 'package:flutter/material.dart';

class UserHeading extends StatelessWidget {
  final ThemeData theme;
  final String page;
  const UserHeading({super.key, required this.theme, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User $page', style: theme.textTheme.displaySmall),
          Row(
            children: [
              Text('Dashboard', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 2.5,
                backgroundColor: theme.dividerColor,
              ),
              const SizedBox(width: 15),
              Text('User', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 2.5,
                backgroundColor: theme.dividerColor,
              ),
              const SizedBox(width: 15),
              Text(
                page,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
