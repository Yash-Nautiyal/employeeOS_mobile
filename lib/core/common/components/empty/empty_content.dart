import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyContent extends StatelessWidget {
  final String icon;
  final String? title;
  final String? description;
  const EmptyContent(
      {super.key, required this.icon, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
          ),
          title != null
              ? Text(
                  title!,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppPallete.grey500),
                )
              : const SizedBox.shrink(),
          description != null
              ? Text(
                  description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: AppPallete.grey600, fontWeight: FontWeight.w600),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
