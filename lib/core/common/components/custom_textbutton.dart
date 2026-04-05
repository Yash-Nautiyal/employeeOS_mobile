import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final Function onClick;
  final Color? backgroundColor;
  final double? padding;
  final bool enabled;

  const CustomTextButton({
    super.key,
    required this.child,
    required this.onClick,
    this.backgroundColor,
    this.padding = 4,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor;
    final Color? effectiveBg = !enabled && bg != null
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.45), bg)
        : bg;

    return TextButton(
        onPressed: enabled ? () => onClick() : null,
        style: effectiveBg != null
            ? ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(effectiveBg),
                side: const WidgetStatePropertyAll(BorderSide.none))
            : null,
        child: Padding(
          padding: EdgeInsets.all(padding!),
          child: child,
        ));
  }
}
