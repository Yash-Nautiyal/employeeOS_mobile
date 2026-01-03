import 'package:flutter/material.dart';
import 'package:employeeos/core/index.dart'
    show KanbanDimensions, showRightSideTaskDetails;
import 'package:employeeos/view/kanban/index.dart'
    show
        DragPayload,
        KanbanColumn,
        KanbanGroupItem,
        KanbanSection,
        KanbanSideMenu,
        KanbanTaskCard;

class KanbanDraggableTask extends StatelessWidget {
  const KanbanDraggableTask({
    super.key,
    required this.theme,
    required this.task,
    required this.fromColumnId,
    required this.fromSection,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.fromColumn,
    required this.allColumns,
    required this.onMoveToColumn,
  });

  final ThemeData theme;
  final KanbanGroupItem task;
  final String fromColumnId;
  final KanbanSection fromSection;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final KanbanColumn fromColumn;
  final List<KanbanColumn> allColumns;
  final void Function(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) onMoveToColumn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KanbanDimensions.kItemGap),
      child: LongPressDraggable<DragPayload>(
        data: DragPayload(
            task: task, fromColumn: fromColumnId, fromSection: fromSection),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        hapticFeedbackOnStart: true,
        onDragStarted: onDragStarted,
        onDragEnd: (_) => onDragEnded(),
        onDragCompleted: onDragEnded,
        onDraggableCanceled: (_, __) => onDragEnded(),
        feedback: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: KanbanDimensions.kColumnWidth),
            child: Opacity(
              opacity: 0.9,
              child: KanbanTaskCard(theme: theme, task: task),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.2,
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: KanbanTaskCard(theme: theme, task: task),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            var currentColumnId = fromColumnId;
            showRightSideTaskDetails(
              context,
              KanbanSideMenu(
                task: task,
                group: fromColumn,
                allColumns: allColumns,
                onMoveColumn: (toColumnId) {
                  if (toColumnId == currentColumnId) return;
                  onMoveToColumn(
                    task,
                    currentColumnId,
                    fromSection,
                    toColumnId,
                  );
                  currentColumnId = toColumnId;
                },
              ),
            );
          },
          child: KanbanTaskCard(theme: theme, task: task),
        ),
      ),
    );
  }
}
