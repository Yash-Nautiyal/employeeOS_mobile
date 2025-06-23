import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FilemanagerHeader extends StatelessWidget {
  const FilemanagerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          "File Manager",
          style: theme.textTheme.displaySmall,
        ),
        const Spacer(),
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(theme.colorScheme.tertiary),
          ),
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-eva_cloud-upload-fill.svg',
                color: theme.scaffoldBackgroundColor,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                "Upload",
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.scaffoldBackgroundColor),
              )
            ],
          ),
        )
      ],
    );
  }
}
