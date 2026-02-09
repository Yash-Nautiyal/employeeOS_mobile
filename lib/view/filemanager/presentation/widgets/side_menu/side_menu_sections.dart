import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class SideMenuSections extends StatelessWidget {
  const SideMenuSections(
      {super.key,
      required this.onToggle,
      required this.title,
      required this.theme,
      required this.onAdd,
      required this.isExpanded,
      required this.child});

  final Function() onToggle;
  final String title;
  final ThemeData theme;
  final VoidCallback? onAdd;
  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // Header - clickable
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (onAdd != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppPallete.successMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  AnimatedRotation(
                    turns: isExpanded ? 0 : 0.5, // 0.5 turns = 180 degrees
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - with animation
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
