// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A reusable popup menu item widget
///
/// Features:
/// - Icon support (both SVG and regular icons)
/// - Selected state styling
/// - Destructive action styling
/// - Theme-aware colors
/// - Consistent padding and layout
class CustomPopupMenuItem extends StatelessWidget {
  const CustomPopupMenuItem({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.svgIcon,
    this.isSelected = false,
    this.isDestructive = false,
    this.iconSize = 20,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.margin = const EdgeInsets.all(2),
    this.borderRadius = 8.0,
  });

  /// The text to display in the menu item
  final String text;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Regular Flutter icon
  final IconData? icon;

  /// SVG icon asset path
  final String? svgIcon;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Whether this is a destructive action (e.g., delete)
  final bool isDestructive;

  /// Size of the icon
  final double iconSize;

  /// Custom text style (overrides theme-based styling)
  final TextStyle? textStyle;

  /// Padding inside the menu item
  final EdgeInsets padding;

  /// Margin around the menu item
  final EdgeInsets margin;

  /// Border radius for the menu item
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(2),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.dividerColor.withOpacity(.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            children: [
              if (icon != null || svgIcon != null) ...[
                _buildIcon(theme),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  style: textStyle ?? _getTextStyle(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final color = _getIconColor(theme);

    if (svgIcon != null) {
      return SvgPicture.asset(
        svgIcon!,
        width: iconSize,
        color: color,
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: color,
      );
    }

    return const SizedBox.shrink();
  }

  Color _getIconColor(ThemeData theme) {
    if (isDestructive) {
      return AppPallete.errorMain;
    }
    return theme.colorScheme.tertiary;
  }

  TextStyle _getTextStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color:
              isDestructive ? AppPallete.errorMain : theme.colorScheme.tertiary,
        ) ??
        const TextStyle();
  }
}

/// A specialized popup menu item for user permissions
class PermissionMenuItem extends CustomPopupMenuItem {
  const PermissionMenuItem({
    super.key,
    required super.text,
    required super.onTap,
    required super.svgIcon,
    required super.isSelected,
  });
}

/// A specialized popup menu item for destructive actions
class DestructiveMenuItem extends CustomPopupMenuItem {
  const DestructiveMenuItem({
    super.key,
    required super.text,
    required super.onTap,
    super.svgIcon =
        'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
    super.icon,
  }) : super(isDestructive: true);
}
