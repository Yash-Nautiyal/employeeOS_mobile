import 'dart:io';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group_card.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_header.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/kanban_board.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> with TickerProviderStateMixin {
  final _controller = KanbanBoardController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use a key based on the theme's brightness to force a rebuild when it changes.
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: KanbanBoard(
                key: ValueKey(theme.brightness),
                onGroupMove: (oldListIndex, newListIndex) {},
                onGroupItemMove:
                    (oldCardIndex, newCardIndex, oldListIndex, newListIndex) {},
                controller: _controller,
                groups: kanbanGroups,
                groupHeaderBuilder: (context, groupId) =>
                    groupHeaderBuilder(context, groupId, theme),
                boardDecoration:
                    BoxDecoration(color: theme.scaffoldBackgroundColor),
                groupDecoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                groupConstraints: groupConstraints,
                itemGhost: ghost,
                groupGhost: Container(
                  color: Colors.red,
                  height: 100,
                  width: 100,
                ),
                groupItemBuilder: (context, groupId, itemIndex) =>
                    groupItemBuilder(context, groupId, itemIndex, theme),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get ghost => const Center(
        child: Text(
          "Drop your task here",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget groupHeaderBuilder(
      BuildContext context, String groupId, ThemeData theme) {
    final groupIndex =
        kanbanGroups.indexWhere((element) => element.id == groupId);
    final group = kanbanGroups[groupIndex];
    return KanbanHeader(
      theme: theme,
      stateColor: group.customData?.color ?? Colors.transparent,
      title: group.customData?.title ?? '',
    );
  }

  Widget groupItemBuilder(
      BuildContext context, String groupId, int itemIndex, ThemeData theme) {
    final groupIndex =
        kanbanGroups.indexWhere((element) => element.id == groupId);
    final groupItem = kanbanGroups[groupIndex].items[itemIndex];
    return KanbanGroupCard(
      theme: theme,
      title: groupItem.title,
      date: groupItem.date,
    );
  }

  double get groupWidth =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? 350
          : MediaQuery.sizeOf(context).width * 0.8;

  BoxConstraints get groupConstraints => BoxConstraints(
        minWidth: groupWidth,
        maxWidth: groupWidth,
      );
}
