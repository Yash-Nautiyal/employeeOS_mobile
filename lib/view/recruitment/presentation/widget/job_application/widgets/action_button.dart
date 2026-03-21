import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RoundActionButton extends StatelessWidget {
  const RoundActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: 20,
          ),
        ),
      ),
    );
  }
}

class ResumeIconButton extends StatelessWidget {
  const ResumeIconButton({
    super.key,
    required this.theme,
    required this.resumeUrl,
  });

  final ThemeData theme;
  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            'assets/icons/common/solid/ic-solar_file-text-bold.svg',
            colorFilter: ColorFilter.mode(
              theme.colorScheme.tertiary,
              BlendMode.srcIn,
            ),
            width: 18,
          ),
        ),
      ),
    );
  }
}
