import 'package:employeeos/core/theme/app_pallete.dart';
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
    final button = ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: SvgPicture.asset(
        'assets/icons/nav/ic-calendar.svg',
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          AppPallete.white,
          BlendMode.srcIn,
        ),
      ),
      label: const Text('Schedule with Google Calendar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppPallete.grey700
            : AppPallete.grey400,
        disabledBackgroundColor: theme.disabledColor.withOpacity(0.2),
        disabledForegroundColor: theme.disabledColor,
        foregroundColor: AppPallete.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}

