import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/common/components/popup/popup.dart';

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
    final GlobalKey _popupAnchorKey = GlobalKey();
    final LayerLink _layerLink = LayerLink();
    final ResponsivePopupController _popupController =
        ResponsivePopupController();

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

          Popup(
              popupAnchorKey: _popupAnchorKey,
              layerLink: _layerLink,
              popupController: _popupController,
              preferredPosition: PopupPreferredPosition.bottom,
              arrowOffset: 0.5,
              arrowColor: theme.brightness == Brightness.dark
                  ? AppPallete.darkBackgroundGradient.colors[1]
                  : AppPallete.lightBackgroundGradient.colors[1],
              icon: const Icon(Icons.more_vert_rounded),
              items: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ResponsivePopupItem(
                    title: 'Rename',
                    svgIcon: 'assets/icons/common/solid/ic-solar_pen-bold.svg',
                    onTap: () {
                      _popupController.hide();
                      onRename();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0)
                      .copyWith(top: 10),
                  child: ResponsivePopupItem(
                    title: 'Clear tasks',
                    svgIcon:
                        'assets/icons/common/solid/ic-solar-eraser-bold.svg',
                    onTap: () {
                      _popupController.hide();
                      onClear();
                    },
                  ),
                ),
                DestructivePopupItem(
                    title: 'Remove',
                    onTap: () {
                      _popupController.hide();
                      showCustomToast(
                          context: context,
                          type: ToastificationType.info,
                          title: 'Feature not accessible in demo mode');
                      // onDelete();
                    }),
              ])
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
