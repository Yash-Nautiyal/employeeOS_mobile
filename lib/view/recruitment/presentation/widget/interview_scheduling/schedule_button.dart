import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScheduleButton extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final bool isEnabled;

  const ScheduleButton({
    super.key,
    required this.theme,
    required this.onPressed,
    this.isFullWidth = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isWideScreen = !isPortrait || wideScreen;
    final button = CustomTextButton(
      padding: isWideScreen ? 4 : 0,
      onClick: isEnabled ? () => onPressed() : () {},
      backgroundColor:
          isEnabled ? theme.colorScheme.tertiary : theme.colorScheme.surface,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/nav/ic-calendar.svg',
            width: 20,
            colorFilter: ColorFilter.mode(
              isEnabled ? theme.scaffoldBackgroundColor : theme.disabledColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text('Schedule with Google Calendar',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isEnabled
                      ? theme.scaffoldBackgroundColor
                      : theme.disabledColor,
                )),
          ),
        ],
      ),
    );

    return button;
  }
}
