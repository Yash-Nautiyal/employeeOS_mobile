import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanHeader extends StatelessWidget {
  const KanbanHeader({
    super.key,
    required this.theme,
    required this.title,
    required this.count,
    required this.onAddTask,
    required this.onDelete,
    required this.onClear,
    required this.onRename,
  });

  final ThemeData theme;
  final String title;
  final int count;
  final VoidCallback onAddTask;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onAddTask,
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
              color: theme.disabledColor,
            ),
          ),
          CustomPopup(
            contentPadding: EdgeInsets.zero,
            content: Container(
              constraints: const BoxConstraints(
                maxWidth: 150,
                minWidth: 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PermissionMenuItem(
                    text: 'Rename',
                    onTap: () => onRename(),
                    svgIcon: 'assets/icons/common/solid/ic-solar_pen-bold.svg',
                    isSelected: false,
                  ),
                  PermissionMenuItem(
                    text: 'Clear tasks',
                    onTap: () => onClear(),
                    svgIcon:
                        'assets/icons/common/solid/ic-solar-eraser-bold.svg',
                    isSelected: false,
                  ),
                  CustomDivider(
                    color: theme.dividerColor,
                  ),
                  DestructiveMenuItem(
                    text: 'Remove',
                    onTap: () => onDelete(),
                  ),
                ],
              ),
            ),
            child: Icon(Icons.more_horiz, color: theme.colorScheme.tertiary),
          ),
          // PopupMenuButton<String>(
          //   icon: Icon(Icons.more_horiz, color: theme.colorScheme.tertiary),
          //   onSelected: (val) {
          //     switch (val) {
          //       case 'edit':
          //         onRename();
          //         break;
          //       case 'clear':
          //         onClear();
          //         break;
          //       case 'delete':
          //         onDelete();
          //         break;
          //     }
          //   },
          //   itemBuilder: (context) => const [
          //     PopupMenuItem(value: 'edit', child: Text('Edit name')),
          //     PopupMenuItem(value: 'clear', child: Text('Clear tasks')),
          //     PopupMenuItem(
          //       value: 'delete',
          //       child: Text('Delete column'),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
