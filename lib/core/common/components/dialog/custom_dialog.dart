import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.child,
    this.maxWidth = 560,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 500;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;

    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: 20, vertical: isWideScreen ? 10 : 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: child),
    );
  }
}
