import 'package:employeeos/core/common/components/custom_switcher.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group_card.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_header.dart';
import 'package:flutter/material.dart';

import 'package:appflowy_board/appflowy_board.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final AppFlowyBoardController controller = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
    },
  );
  bool isShriked = false;
  late AppFlowyBoardScrollController boardController;

  @override
  void initState() {
    super.initState();
    boardController = AppFlowyBoardScrollController();
    controller.addGroups(kanbanGroups);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final config = AppFlowyBoardConfig(
      groupBackgroundColor: theme.colorScheme.surface,
      stretchGroupHeight: isShriked,
      groupCornerRadius: 16,
      groupBodyPadding: const EdgeInsets.only(bottom: 10),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: 120.0, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Kanban",
                style: theme.textTheme.displaySmall,
              ),
              const Spacer(),
              Text(
                "Fixed Column",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 7),
              CustomSwitch(
                height: 22,
                width: 40,
                activeColor: AppPallete.successMain,
                value: isShriked,
                onChanged: (value) {
                  setState(() {
                    isShriked = value;
                  });
                },
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: AppFlowyBoard(
                controller: controller,
                cardBuilder: (context, group, item) {
                  final kanbanItem = item as KanbanGroupItem;
                  return AppFlowyGroupCard(
                    boxConstraints: const BoxConstraints(minHeight: 20),
                    key: ValueKey(kanbanItem.itemId),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: KanbanGroupCard(
                      group: group,
                      theme: Theme.of(context),
                      title: kanbanItem.title,
                      date: kanbanItem.date,
                      task: kanbanItem,
                    ),
                  );
                },
                scrollController: ScrollController(),
                boardScrollController: boardController,
                headerBuilder: (context, columnData) {
                  return KanbanHeader(
                      columnData: columnData,
                      controller: controller,
                      theme: theme);
                },
                groupConstraints:
                    const BoxConstraints(maxWidth: 300, minWidth: 250),
                config: config),
          ),
        ],
      ),
    );
  }
}
