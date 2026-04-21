import 'package:flutter/material.dart';

class CustomTitleHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String? subtitle;

  const CustomTitleHeader(
      {super.key, required this.theme, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: subtitle != null ? 42 : 32,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle != null
                  ? Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
