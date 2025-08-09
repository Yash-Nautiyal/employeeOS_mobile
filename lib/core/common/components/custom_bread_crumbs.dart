import 'package:flutter/material.dart';

class CustomBreadCrumbs extends StatelessWidget {
  final ThemeData theme;
  final String heading;
  final List<String> routes;
  const CustomBreadCrumbs(
      {super.key,
      required this.theme,
      required this.heading,
      required this.routes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: theme.textTheme.displaySmall),
          Row(
            children: [
              Text(routes[0], style: theme.textTheme.bodyMedium),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 2.5,
                backgroundColor: theme.dividerColor,
              ),
              const SizedBox(width: 15),
              Text(routes[1], style: theme.textTheme.bodyMedium),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 2.5,
                backgroundColor: theme.dividerColor,
              ),
              const SizedBox(width: 15),
              Text(
                routes[2],
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
