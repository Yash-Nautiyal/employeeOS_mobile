import 'package:employeeos/view/kanban/domain/index.dart' show KanbanGroupItem;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:employeeos/core/index.dart' show AppPallete, KanbanDimensions;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  color: iconColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (task.attachments.isNotEmpty) ...[
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 50),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final attachment = task.attachments[index];
                    return Image.network(attachment.fileUrl);
                  },
                ),
              )
            ],
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic-calender.svg',
                  color: theme.dividerColor,
                ),
                const SizedBox(width: 5),
                Text(
                  task.displayDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (task.assignees.isNotEmpty)
                  SizedBox(
                    width: 100,
                    height: 32,
                    child: Stack(
                      children: [
                        ...task.assignees.take(3).toList().asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final assignee = entry.value;
                            return Positioned(
                              right: index * 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: assignee.avatarUrl != null &&
                                          assignee.avatarUrl!.isNotEmpty
                                      ? NetworkImage(assignee.avatarUrl!)
                                      : null,
                                  child: assignee.avatarUrl == null ||
                                          assignee.avatarUrl!.isEmpty
                                      ? Text(
                                          assignee.initials,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppPallete.black),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        if (task.assignees.length > 3)
                          Positioned(
                            right: 3 * 20.0,
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.6),
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '+${task.assignees.length - 3}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColorLight,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
