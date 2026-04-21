// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomDropdownPainter extends CustomPainter {
  final BuildContext context;
  final ThemeData theme;

  CustomDropdownPainter({required this.context, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Create the unified path (container + triangle)
    final path = Path();

    // Container dimensions
    final containerWidth = size.width;
    final containerHeight = size.height - 12; // Account for triangle height
    const borderRadius = 8.0;
    const triangleHeight = 12.0;
    const triangleWidth = 20.0;
    final triangleOffset = containerWidth - 40; // Position from right edge

    // Start from top-left, going clockwise
    path.moveTo(borderRadius, triangleHeight);

    // Top edge until triangle start
    path.lineTo(triangleOffset, triangleHeight);

    // Triangle - going up and back down
    path.lineTo(triangleOffset + triangleWidth / 2, 0);
    path.lineTo(triangleOffset + triangleWidth, triangleHeight);

    // Continue top edge
    path.lineTo(containerWidth - borderRadius, triangleHeight);

    // Top-right corner
    path.quadraticBezierTo(
      containerWidth,
      triangleHeight,
      containerWidth,
      triangleHeight + borderRadius,
    );

    // Right edge
    path.lineTo(
      containerWidth,
      containerHeight + triangleHeight - borderRadius,
    );

    // Bottom-right corner
    path.quadraticBezierTo(
      containerWidth,
      containerHeight + triangleHeight,
      containerWidth - borderRadius,
      containerHeight + triangleHeight,
    );

    // Bottom edge
    path.lineTo(borderRadius, containerHeight + triangleHeight);

    // Bottom-left corner
    path.quadraticBezierTo(
      0,
      containerHeight + triangleHeight,
      0,
      containerHeight + triangleHeight - borderRadius,
    );

    // Left edge
    path.lineTo(0, triangleHeight + borderRadius);

    // Top-left corner
    path.quadraticBezierTo(0, triangleHeight, borderRadius, triangleHeight);

    path.close();

    // Draw shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.save();
    canvas.translate(0, 2); // Shadow offset
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Create gradient paint
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 84, 47, 45)
              : const Color.fromARGB(255, 254, 237, 221),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 27, 30, 39)
              : const Color.fromARGB(255, 251, 251, 251),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 27, 30, 39)
              : const Color.fromARGB(255, 251, 251, 251),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 33, 70, 80)
              : const Color.fromARGB(255, 225, 255, 255),
        ],
        stops: theme.brightness == Brightness.dark
            ? [0.0, .17, .834, 1]
            : [0.05, 0.3, .7, 0.99],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw the main shape with gradient
    canvas.drawPath(path, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
