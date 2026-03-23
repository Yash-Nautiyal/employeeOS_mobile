import 'package:flutter/material.dart';
import 'package:employeeos/view/kanban/domain/index.dart'
    show DragPayload, KanbanGroupItem, KanbanSection;

class DropSlot extends StatelessWidget {
  const DropSlot({
    super.key,
    required this.section,
    required this.columnId,
    required this.index,
    required this.hoverColumnId,
    required this.hoverSection,
    required this.hoverIndex,
    required this.hoverTask,
    required this.onDragMove,
    required this.onHover,
    required this.onHoverExit,
    required this.onAccept,
  });

  final KanbanSection section;
  final String columnId;
  final int index;

  final String? hoverColumnId;
  final KanbanSection? hoverSection;
  final int? hoverIndex;
  final KanbanGroupItem? hoverTask;

  final void Function(Offset globalOffset) onDragMove;
  final void Function(
    String columnId,
    KanbanSection section,
    int index,
    KanbanGroupItem task,
  ) onHover;
  final VoidCallback onHoverExit;
  final void Function(DragPayload payload, int index) onAccept;

  bool get _isActive =>
      hoverColumnId == columnId &&
      hoverSection == section &&
      hoverIndex == index;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) {
        // Hard rule: createdByMe cannot drop into assignedToMe and vice versa.
        if (details.data.fromSection != section) return false;
        onHover(columnId, section, index, details.data.task);
        return true;
      },
      onMove: (details) => onDragMove(details.offset),
      onLeave: (_) => onHoverExit(),
      onAcceptWithDetails: (details) => onAccept(details.data, index),
      builder: (context, candidates, rejects) {
        final show = _isActive || candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: show ? 14 : 0,
          decoration: BoxDecoration(
            color: _isActive
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
