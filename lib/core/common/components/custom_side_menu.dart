import 'dart:ui';

import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:flutter/material.dart';

Future<void> showRightSideTaskDetails(
  BuildContext context,
  Widget child, {
  double? widthFactor,
  double maxWidth = 400,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final theme = Theme.of(context);
  final wideScreen = MediaQuery.of(context).size.width > 700;
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final isWideScreen = !isPortrait || wideScreen;
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = widthFactor != null
      ? screenWidth * widthFactor
      : (isWideScreen ? screenWidth * 0.65 : screenWidth * 0.85);
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              width: dialogWidth,
              height: double.infinity,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                      height: screenHeight,
                      decoration: BoxDecoration(
                        gradient: theme.brightness == Brightness.dark
                            ? AppPallete.darkBackgroundGradient
                            : AppPallete.lightBackgroundGradient,
                      ),
                      child: child),
                ),
              )),
        ),
      );
    },
    // Optional: animate it in from the right side
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Start just off the right edge
        end: Offset.zero,
      ).animate(animation);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
