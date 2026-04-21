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
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  width: dialogWidth,
                  height: double.infinity,
                  child: ClipRRect(
                    child: Container(
                        height: screenHeight,
                        decoration: BoxDecoration(
                            gradient:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(102, 46, 43, 0.85),
                                          Color.fromRGBO(26, 26, 32, 0.851),
                                          Color.fromRGBO(32, 39, 46, 0.851),
                                          Color.fromRGBO(33, 71, 91, 0.85)
                                        ],
                                        stops: [0.0, .26, .83, 1],
                                        begin: Alignment(-1.8, 1),
                                        end: Alignment(1.2, -1),
                                      )
                                    : AppPallete.lightBackgroundGradient),
                        child: child),
                  )),
            ),
          ),
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
