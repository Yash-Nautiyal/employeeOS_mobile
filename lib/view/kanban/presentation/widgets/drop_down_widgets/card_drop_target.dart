import 'package:flutter/material.dart';

import '../../../domain/index.dart' show DragPayload, KanbanGroupItem, KanbanSection;

class CardDropTarget extends StatelessWidget {
  const CardDropTarget({super.key, 
    required this.section,
    required this.columnId,
    required this.baseIndex,
    required this.task,
    required this.onDragMove,
    required this.onHover,
    required this.onHoverExit,
    required this.onAccept,
    required this.child,
  });

  final KanbanSection section;
  final String columnId;
  final int baseIndex;
  final KanbanGroupItem task;

  final void Function(Offset globalOffset) onDragMove;
  final void Function(
    String columnId,
    KanbanSection section,
    int index,
    KanbanGroupItem task,
  ) onHover;
  final VoidCallback onHoverExit;
  final void Function(DragPayload payload, int index) onAccept;
  final Widget child;

  int _indexForOffset(BuildContext context, Offset globalOffset) {
    final box = context.findRenderObject();
    if (box is! RenderBox) return baseIndex;
    final local = box.globalToLocal(globalOffset);
    final mid = box.size.height / 2;
    return local.dy < mid ? baseIndex : baseIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) {
        if (details.data.fromSection != section) return false;
        final idx = _indexForOffset(context, details.offset);
        onHover(columnId, section, idx, details.data.task);
        return true;
      },
      onMove: (details) {
        if (details.data.fromSection != section) return;
        final idx = _indexForOffset(context, details.offset);
        onHover(columnId, section, idx, details.data.task);
        onDragMove(details.offset);
      },
      onLeave: (_) => onHoverExit(),
      onAcceptWithDetails: (details) {
        final idx = _indexForOffset(context, details.offset);
        onAccept(details.data, idx);
      },
      builder: (context, candidates, rejects) => child,
    );
  }
}
