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
                child: Container(
                    height: screenHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.brightness == Brightness.dark
                              ? const Color.fromARGB(255, 56, 32, 31)
                              : AppPallete.errorLighter,
                          theme.brightness == Brightness.dark
                              ? const Color.fromARGB(255, 27, 31, 37)
                              : const Color.fromARGB(255, 251, 251, 251),
                          theme.brightness == Brightness.dark
                              ? const Color.fromARGB(255, 24, 27, 32)
                              : const Color.fromARGB(255, 251, 251, 251),
                          theme.brightness == Brightness.dark
                              ? const Color.fromARGB(255, 38, 55, 66)
                              : const Color.fromARGB(255, 212, 251, 251),
                        ],
                        stops: theme.brightness == Brightness.dark
                            ? [0.0, .17, .84, .98]
                            : [0.05, 0.3, .7, 0.99],
                        begin: const Alignment(-1.7, 1),
                        end: const Alignment(1.2, -1),
                      ),
                    ),
                    child: child),
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
