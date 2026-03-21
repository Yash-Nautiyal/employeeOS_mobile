import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.colors,
    required this.textTheme,
  });

  final String status;
  final Map<String, Color> colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors['lightColor']?.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: colors['lightColor']!.withValues(alpha: 0.25)),
      ),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              theme.brightness == Brightness.dark
                  ? colors['darkColor']!
                  : colors['lightColor']!,
              theme.brightness == Brightness.dark
                  ? colors['lightColor']!
                  : colors['darkColor']!
            ], // Replace with your desired colors
            begin: theme.brightness == Brightness.dark
                ? Alignment.topLeft
                : Alignment.bottomRight,
            end: theme.brightness == Brightness.dark
                ? Alignment.bottomRight
                : Alignment.topLeft,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
        },
        child: Text(
          status,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
