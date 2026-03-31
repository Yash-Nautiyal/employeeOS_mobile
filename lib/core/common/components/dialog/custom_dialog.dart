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
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final wideScreen = size.width > 500;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final isLandscape = size.width > size.height;
    final availableH = size.height - padding.top - padding.bottom;
    // Short landscape (e.g. phone rotated): cap height so content scrolls inside.
    final maxH = (availableH - (isLandscape ? 16 : 28)).clamp(220.0, 520.0);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? 8 : (isWideScreen ? 10 : 0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxH,
        ),
        child: child,
      ),
    );
  }
}
