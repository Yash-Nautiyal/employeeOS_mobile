import 'package:employeeos/view/kanban/domain/index.dart';
import 'package:flutter/material.dart';
import 'package:employeeos/core/index.dart';
import 'package:employeeos/view/kanban/presentation/index.dart';

class KanbanColumnView extends StatelessWidget {
  const KanbanColumnView({
    super.key,
    required this.bloc,
    required this.theme,
    required this.column,
    required this.allColumns,
    required this.fixed,
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
    required this.onAddTask,
    required this.onDeleteColumn,
    required this.onClearColumn,
    required this.onRenameColumn,
    required this.onPriorityChanged,
    required this.onAssigneesChanged,
  });

  final KanbanBloc bloc;
  final bool fixed;
  final int? hoverIndex;
  final ThemeData theme;
  final KanbanColumn column;
  final List<KanbanColumn> allColumns;
  final String? hoverColumnId;
  final String? draggingTaskId;
  final KanbanGroupItem? hoverTask;
  final KanbanSection? hoverSection;
  final VoidCallback onDragEnded;
  final void Function(String taskId) onDragStarted;
  final void Function(Offset globalOffset) onDragMove;
  final void Function(
    String columnId,
    KanbanSection section,
    int index,
    KanbanGroupItem task,
  ) onHover;
  final VoidCallback onHoverExit;
  final void Function(DragPayload payload, KanbanSection section, int index)
      onAccept;
  final void Function(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) onMoveTaskToColumn;
  final VoidCallback onAddTask;
  final VoidCallback onDeleteColumn;
  final VoidCallback onClearColumn;
  final VoidCallback onRenameColumn;
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

  @override
  Widget build(BuildContext context) {
    final columnBg = theme.colorScheme.surface;

    return ConstrainedBox(
      constraints:
          const BoxConstraints.tightFor(width: KanbanDimensions.kColumnWidth),
      child: Container(
        decoration: BoxDecoration(
          color: columnBg,
          borderRadius: BorderRadius.circular(KanbanDimensions.kColumnRadius),
        ),
        padding: KanbanDimensions.kColumnPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KanbanHeader(
              theme: theme,
              title: column.title,
              count: column.totalCount,
              onAddTask: onAddTask,
              onDelete: onDeleteColumn,
              onClear: onClearColumn,
              onRename: onRenameColumn,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<DragPayload>(
                // Column-level target ensures you can drop into empty sections/columns.
                onWillAcceptWithDetails: (details) {
                  final section = details.data.fromSection;
                  final toIndex = section == KanbanSection.createdByMe
                      ? column.createdByMe.length
                      : column.assignedToMe.length;
                  onHover(column.id, section, toIndex, details.data.task);
                  return true;
                },
                onMove: (details) => onDragMove(details.offset),
                onLeave: (_) => onHoverExit(),
                onAcceptWithDetails: (details) {
                  final section = details.data.fromSection;
                  final toIndex = section == KanbanSection.createdByMe
                      ? column.createdByMe.length
                      : column.assignedToMe.length;
                  onAccept(details.data, section, toIndex);
                },
                builder: (context, candidates, rejects) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      KanbanSectionView(
                        bloc: bloc,
                        theme: theme,
                        title: 'Created by me',
                        tasks: column.createdByMe,
                        section: KanbanSection.createdByMe,
                        columnId: column.id,
                        allColumns: allColumns,
                        hoverColumnId: hoverColumnId,
                        hoverSection: hoverSection,
                        hoverIndex: hoverIndex,
                        hoverTask: hoverTask,
                        draggingTaskId: draggingTaskId,
                        onDragMove: onDragMove,
                        onDragStarted: onDragStarted,
                        onDragEnded: onDragEnded,
                        onHover: onHover,
                        onHoverExit: onHoverExit,
                        onAccept: (payload, index) =>
                            onAccept(payload, KanbanSection.createdByMe, index),
                        onMoveTaskToColumn: onMoveTaskToColumn,
                        onPriorityChanged: onPriorityChanged,
                        onAssigneesChanged: onAssigneesChanged,
                      ),
                      KanbanSectionView(
                        bloc: bloc,
                        theme: theme,
                        title: 'Assigned to me',
                        tasks: column.assignedToMe,
                        section: KanbanSection.assignedToMe,
                        columnId: column.id,
                        allColumns: allColumns,
                        hoverColumnId: hoverColumnId,
                        hoverSection: hoverSection,
                        hoverIndex: hoverIndex,
                        hoverTask: hoverTask,
                        draggingTaskId: draggingTaskId,
                        onDragMove: onDragMove,
                        onDragStarted: onDragStarted,
                        onDragEnded: onDragEnded,
                        onHover: onHover,
                        onHoverExit: onHoverExit,
                        onAccept: (payload, index) => onAccept(
                          payload,
                          KanbanSection.assignedToMe,
                          index,
                        ),
                        onMoveTaskToColumn: onMoveTaskToColumn,
                        onPriorityChanged: onPriorityChanged,
                        onAssigneesChanged: onAssigneesChanged,
                      ),
                    ],
                  );
                },
              ),
            ),
            if (!fixed) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
