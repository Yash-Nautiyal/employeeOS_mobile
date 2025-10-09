import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Future<void> showRightSideTaskDetails(BuildContext context, Widget child) {
  final screenHeight = MediaQuery.of(context).size.height;
  final theme = Theme.of(context);
  final wideScreen = MediaQuery.of(context).size.width > 700;
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final isWideScreen = !isPortrait || wideScreen;
  return showGeneralDialog(
    context: context,
    // Tapping outside the dialog will dismiss it
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    // A semi-transparent background
    barrierColor: Colors.black54,
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      // The actual widget for your side sheet
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          // Material gives it a “surface” so it can have its own background color, elevation, etc.
          child: SizedBox(
              width: isWideScreen ? 65.w : 85.w,
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
