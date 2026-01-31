import 'package:flutter/material.dart';

class SmartPopupItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;

  const SmartPopupItem({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
