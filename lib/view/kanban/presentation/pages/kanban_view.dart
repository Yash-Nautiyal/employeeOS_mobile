import 'package:appflowy_board/appflowy_board.dart';
import 'package:employeeos/core/common/components/custom_switcher.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group_card.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_header.dart';
import 'package:flutter/material.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({Key? key}) : super(key: key);

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
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: AppFlowyBoard(
                controller: controller,
                cardBuilder: (context, group, groupItem) {
                  return AppFlowyGroupCard(
                    key: ValueKey(groupItem.id),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: _buildCard(groupItem, group, theme),
                  );
                },
                boardScrollController: boardController,
                headerBuilder: (context, columnData) {
                  return KanbanHeader(
                      theme: theme,
                      columnData: columnData,
                      controller: controller);
                },
                groupConstraints:
                    const BoxConstraints(maxWidth: 300, minWidth: 250),
                config: config),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(AppFlowyGroupItem item, AppFlowyGroupData<dynamic> group,
      ThemeData theme) {
    final task = item as KanbanGroupItem;
    return KanbanGroupCard(
        title: task.title,
        date: task.date,
        theme: theme,
        task: task,
        group: group);
  }
}
