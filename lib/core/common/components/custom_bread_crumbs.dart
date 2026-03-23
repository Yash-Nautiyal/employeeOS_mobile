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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(heading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displaySmall),
              ),
            ],
          ),
          Wrap(
            spacing: -2,
            runSpacing: 0,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
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
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
