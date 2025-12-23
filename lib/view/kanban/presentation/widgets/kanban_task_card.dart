import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:employeeos/core/index.dart' show AppPallete, KanbanDimensions;
import 'package:employeeos/view/kanban/index.dart' show KanbanGroupItem;

class KanbanTaskCard extends StatelessWidget {
  const KanbanTaskCard({super.key, required this.theme, required this.task});

  final ThemeData theme;
  final KanbanGroupItem task;

  @override
  Widget build(BuildContext context) {
    final priority = task.priority.toLowerCase();
    final String iconPath = priority == 'low'
        ? 'assets/icons/arrow/ic-solar_double-alt-arrow-down-bold-duotone.svg'
        : priority == 'medium'
            ? 'assets/icons/arrow/ic-solar_double-alt-arrow-right-bold-duotone.svg'
            : 'assets/icons/arrow/ic-solar_double-alt-arrow-up-bold-duotone.svg';
    final Color iconColor = priority == 'low'
        ? AppPallete.infoMain
        : priority == 'medium'
            ? AppPallete.warningMain
            : AppPallete.errorMain;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(KanbanDimensions.kItemRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  color: iconColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic-calender.svg',
                  color: theme.dividerColor,
                ),
                const SizedBox(width: 5),
                Text(
                  (task.dueDate.isNotEmpty ? task.dueDate : task.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const CircleAvatar(radius: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
