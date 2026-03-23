import 'package:employeeos/core/index.dart' show CustomDivider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResponsivePopupItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgIcon;
  final VoidCallback onTap;
  final Color? color;

  const ResponsivePopupItem({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.color,
    this.svgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: color ?? Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 10),
          ],
          if (svgIcon != null) ...[
            SvgPicture.asset(svgIcon!,
                width: 20,
                color: color ?? Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class DestructivePopupItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String svgIcon;
  final Color color;
  const DestructivePopupItem({
    super.key,
    required this.onTap,
    this.title = 'Delete',
    this.svgIcon =
        'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        CustomDivider(
          color: theme.dividerColor.withAlpha(100),
          dashWidth: 2.3,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ResponsivePopupItem(
            title: title,
            svgIcon:
                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
            color: color,
            onTap: () => onTap(),
          ),
        ),
      ],
    );
  }
}

class ViewPopupItem extends ResponsivePopupItem {
  const ViewPopupItem({
    super.key,
    super.title = 'View',
    required super.onTap,
    super.svgIcon = 'assets/icons/common/solid/ic-solar_eye-bold.svg',
    super.color,
  });
}

class EditPopupItem extends ResponsivePopupItem {
  const EditPopupItem({
    super.key,
    super.title = 'Edit',
    required super.onTap,
    super.svgIcon = 'assets/icons/common/solid/ic-solar_pen-bold.svg',
    super.color,
  });
}
