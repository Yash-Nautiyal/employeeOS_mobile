import 'package:employeeos/core/index.dart' show AppPallete, CustomTextButton;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'action_button.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.theme,
    required this.status,
    required this.resumeUrl,
  });

  final ThemeData theme;
  final String status;
  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    final isPending = status.toLowerCase() == 'pending';

    return Row(
      children: [
        Expanded(
          child: CustomTextButton(
            padding: 2,
            backgroundColor: theme.colorScheme.tertiary,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Resume: $resumeUrl')),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/common/solid/ic-solar_file-text-bold.svg',
                  colorFilter: ColorFilter.mode(
                    theme.scaffoldBackgroundColor,
                    BlendMode.srcIn,
                  ),
                  width: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Resume',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.scaffoldBackgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isPending) ...[
          const SizedBox(width: 8),
          RoundActionButton(
            icon: 'assets/icons/common/solid/ic-solar-check-circle-bold.svg',
            color: AppPallete.successMain,
            onPressed: () {},
          ),
          const SizedBox(width: 6),
          RoundActionButton(
            icon: 'assets/icons/common/solid/ic-solar_close-circle-bold.svg',
            color: theme.colorScheme.error,
            onPressed: () {},
          ),
        ],
      ],
    );
  }
}
