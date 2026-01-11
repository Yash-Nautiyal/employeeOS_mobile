import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart' as popup;

/// A reusable custom popup widget that can be used throughout the app
///
/// Features:
/// - Theme-aware styling
/// - Multiple popup types (default, gradient, menu)
/// - Customizable content and appearance
/// - Built-in animations and backdrop
class CustomPopup extends StatelessWidget {
  const CustomPopup({
    super.key,
    required this.child,
    required this.content,
    this.arrowColor,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.contentPadding,
    this.constraints,
    this.barrierColor = Colors.black26,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showArrow = true,
    this.contentDecoration,
    this.anchorKey,
  });

  /// The widget that triggers the popup when tapped
  final Widget child;

  /// The content to display inside the popup
  final Widget content;

  /// Custom arrow color (overrides theme-based color)
  final Color? arrowColor;

  /// Custom background color (overrides theme-based color)
  final Color? backgroundColor;

  /// Border radius for the popup content
  final double borderRadius;

  /// Padding inside the popup content
  final EdgeInsets? contentPadding;

  /// Constraints for the popup content
  final BoxConstraints? constraints;

  /// Color of the barrier behind the popup
  final Color barrierColor;

  /// Animation duration for popup show/hide
  final Duration animationDuration;

  /// Whether to show the popup arrow
  final bool showArrow;

  /// Custom decoration for the popup content (overrides type-based decoration)
  final BoxDecoration? contentDecoration;

  /// Anchor key for the popup
  final GlobalKey<popup.CustomPopupState>? anchorKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return popup.CustomPopup(
      anchorKey: anchorKey,
      barrierColor: theme.brightness == Brightness.dark
          ? Colors.black.withAlpha(200)
          : Colors.black26,
      animationDuration: animationDuration,
      arrowColor: _getArrowColor(theme),
      contentPadding: contentPadding ?? EdgeInsets.zero,
      contentDecoration: contentDecoration ?? _getContentDecoration(theme),
      content: _buildContent(),
      showArrow: showArrow,
      child: child,
    );
  }

  Widget _buildContent() {
    Widget contentWidget = content;

    if (constraints != null) {
      contentWidget = Container(
        constraints: constraints,
        child: contentWidget,
      );
    }

    return contentWidget;
  }

  Color _getArrowColor(ThemeData theme) {
    if (arrowColor != null) return arrowColor!;

    // If backgroundColor is specified, use that for the arrow
    if (backgroundColor != null) return backgroundColor!;

    return theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 22, 24, 29)
        : theme.cardColor;
  }

  BoxDecoration _getContentDecoration(ThemeData theme) {
    if (backgroundColor != null) {
      return BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: [
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 99, 51, 50)
              : const Color.fromARGB(255, 229, 201, 186),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 23, 19, 19)
              : const Color.fromARGB(255, 244, 242, 242),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 22, 24, 29)
              : const Color.fromARGB(255, 244, 242, 242),
          theme.brightness == Brightness.dark
              ? const Color.fromARGB(255, 33, 45, 52)
              : const Color.fromARGB(255, 212, 251, 251),
        ],
        stops: theme.brightness == Brightness.dark
            ? [0.2, .4, .84, .98]
            : [0.2, 0.4, .8, 0.99],
        begin: const Alignment(-2.1, 1),
        end: const Alignment(1.1, -1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
