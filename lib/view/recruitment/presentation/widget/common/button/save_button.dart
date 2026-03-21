import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/index.dart' show CustomTextButton;

class SaveButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final ThemeData theme;
  const SaveButton({
    super.key,
    this.text = 'Save',
    required this.onClick,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextButton(
      backgroundColor: theme.colorScheme.tertiary,
      onClick: onClick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/common/solid/ic-solar-diskette-bold.svg',
            width: 20,
            colorFilter: ColorFilter.mode(
              theme.scaffoldBackgroundColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
