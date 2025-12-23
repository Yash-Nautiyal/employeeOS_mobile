import 'package:flutter/material.dart';
import 'package:employeeos/core/index.dart' show KanbanDimensions;
import 'package:employeeos/view/kanban/index.dart'
    show KanbanGroupItem, KanbanSection, DragPayload, KanbanTaskCard;

class DraggableTask extends StatelessWidget {
  const DraggableTask({
    super.key,
    required this.theme,
    required this.task,
    required this.fromColumnId,
    required this.fromSection,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ThemeData theme;
  final KanbanGroupItem task;
  final String fromColumnId;
  final KanbanSection fromSection;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

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
        child: KanbanTaskCard(theme: theme, task: task),
      ),
    );
  }
}
