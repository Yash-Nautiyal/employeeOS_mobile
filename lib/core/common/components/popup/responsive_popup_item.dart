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
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
          ],
          if (svgIcon != null) ...[
            SvgPicture.asset(svgIcon!, width: 20, color: color),
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
