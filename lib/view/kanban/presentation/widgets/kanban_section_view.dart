import 'package:employeeos/view/kanban/index.dart'
    show
        KanbanSection,
        KanbanGroupItem,
        KanbanAssignee,
        DragPayload,
        DropSlot,
        CardDropTarget,
        KanbanDraggableTask,
        GhostTaskCard,
        KanbanColumn;
import 'package:flutter/material.dart';
import 'package:employeeos/core/index.dart';

class KanbanSectionView extends StatelessWidget {
  const KanbanSectionView({
    super.key,
    required this.theme,
    required this.title,
    required this.tasks,
    required this.section,
    required this.columnId,
    required this.allColumns,
    required this.hoverColumnId,
    required this.hoverSection,
    required this.hoverIndex,
    required this.hoverTask,
    required this.draggingTaskId,
    required this.onDragMove,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onHover,
    required this.onHoverExit,
    required this.onAccept,
    required this.onMoveTaskToColumn,
    required this.onPriorityChanged,
    required this.onAssigneesChanged,
  });

  final ThemeData theme;
  final String title;
  final List<KanbanGroupItem> tasks;
  final KanbanSection section;
  final String columnId;
  final List<KanbanColumn> allColumns;

  final String? hoverColumnId;
  final KanbanSection? hoverSection;
  final int? hoverIndex;
  final KanbanGroupItem? hoverTask;
  final String? draggingTaskId;

  final void Function(Offset globalOffset) onDragMove;
  final void Function(String taskId) onDragStarted;
  final VoidCallback onDragEnded;

  final void Function(
    String columnId,
    KanbanSection section,
    int index,
    KanbanGroupItem task,
  ) onHover;
  final VoidCallback onHoverExit;
  final void Function(DragPayload payload, int index) onAccept;
  final void Function(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) onMoveTaskToColumn;
  final void Function(
    KanbanSection section,
    String columnId,
    String taskId,
    String priority,
  ) onPriorityChanged;
  final void Function(
    KanbanSection section,
    String columnId,
    String taskId,
    List<KanbanAssignee> assignees,
  ) onAssigneesChanged;

  bool get _isHovered => hoverColumnId == columnId && hoverSection == section;

  @override
  Widget build(BuildContext context) {
    // Keep the dragged task in the list so `childWhenDragging` can act as the
    // "placeholder" (React uses an opacity/grayscale placeholder).
    final renderTasks = tasks;

    final canShowGhost = _isHovered && hoverTask != null && hoverIndex != null;
    final ghost = canShowGhost ? hoverTask : null;
    final showHeader = tasks.isNotEmpty || canShowGhost;

    final ghostExtraCount =
        (ghost != null && !tasks.any((t) => t.id == ghost.id)) ? 1 : 0;

    if (!showHeader) {
      // Match React behavior: hide the whole section if empty.
      // (We still show it during hover via `showHeader`.)
      return const SizedBox.shrink();
    }

    List<Widget> children = [];

    // A drop target at the very top (index 0)
    children.add(DropSlot(
      section: section,
      columnId: columnId,
      index: 0,
      hoverColumnId: hoverColumnId,
      hoverSection: hoverSection,
      hoverIndex: hoverIndex,
      hoverTask: hoverTask,
      onDragMove: onDragMove,
      onHover: onHover,
      onHoverExit: onHoverExit,
      onAccept: onAccept,
    ));

    for (int i = 0; i < renderTasks.length; i++) {
      final task = renderTasks[i];

      children.add(CardDropTarget(
        section: section,
        columnId: columnId,
        baseIndex: i,
        task: task,
        onDragMove: onDragMove,
        onHover: onHover,
        onHoverExit: onHoverExit,
        onAccept: onAccept,
        child: KanbanDraggableTask(
          theme: theme,
          task: task,
          fromColumnId: columnId,
          fromSection: section,
          fromColumn: allColumns.firstWhere((c) => c.id == columnId,
              orElse: () => KanbanColumn(
                  id: columnId,
                  title: columnId,
                  createdByMe: const [],
                  assignedToMe: const [])),
          allColumns: allColumns,
          onDragStarted: () => onDragStarted(task.id),
          onDragEnded: onDragEnded,
          onMoveToColumn: onMoveTaskToColumn,
          onPriorityChanged: (priority) => onPriorityChanged(
            section,
            columnId,
            task.id,
            priority,
          ),
          onAssigneesChanged: (assignees) => onAssigneesChanged(
            section,
            columnId,
            task.id,
            assignees,
          ),
        ),
      ));
    }

    // A drop target at the very bottom (index = renderTasks.length)
    children.add(DropSlot(
      section: section,
      columnId: columnId,
      index: renderTasks.length,
      hoverColumnId: hoverColumnId,
      hoverSection: hoverSection,
      hoverIndex: hoverIndex,
      hoverTask: hoverTask,
      onDragMove: onDragMove,
      onHover: onHover,
      onHoverExit: onHoverExit,
      onAccept: onAccept,
    ));

    // Insert the ghost card in the correct index position (between cards).
    // Only show this "ghost" in destination sections (i.e. sections that don't
    // already contain the dragged task).
    if (ghost != null && !tasks.any((t) => t.id == ghost.id)) {
      final idx = hoverIndex!.clamp(0, renderTasks.length);
      // We insert AFTER the drop slot that represents this index.
      final slotWidgetIndex = 0 + (idx == 0 ? 1 : (idx * 2) + 1);
      children.insert(
        slotWidgetIndex,
        Padding(
          padding: const EdgeInsets.only(bottom: KanbanDimensions.kItemGap),
          child: GhostTaskCard(theme: theme, task: ghost),
        ),
      );
    }

    // Apply React-like spacing: cards are spaced by `--item-gap`.
    final spacedChildren = <Widget>[];
    for (final w in children) {
      // Cards already include bottom padding in a couple of places; keep drop slots tight.
      spacedChildren.add(w);
      if (w is CardDropTarget) {
        // The child contains the card; spacing handled in `_DraggableTaskCard`.
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KanbanDimensions.kSectionRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: KanbanDimensions.kSectionHeaderPadding,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withAlpha(100)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$title (${tasks.length + ghostExtraCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: KanbanDimensions.kSectionListPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tasks.isEmpty && ghost == null) const SizedBox(height: 8),
                  ...spacedChildren,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
