import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';

class KanbanStateHelper {
  const KanbanStateHelper._();

  static KanbanColumn? findColumn(List<KanbanColumn> columns, String id) {
    try {
      return columns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static (int, KanbanColumn, KanbanGroupItem)? findTask(
    List<KanbanColumn> columns,
    String columnId,
    KanbanSection section,
    String taskId,
  ) {
    final colIdx = columns.indexWhere((c) => c.id == columnId);
    if (colIdx == -1) return null;
    final col = columns[colIdx];
    final list = section == KanbanSection.createdByMe
        ? col.createdByMe
        : col.assignedToMe;
    final taskIdx = list.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return null;
    return (colIdx, col, list[taskIdx]);
  }

  static (String, KanbanSection, KanbanColumn, int, KanbanGroupItem)?
      findTaskByTaskId(List<KanbanColumn> columns, String taskId) {
    for (var i = 0; i < columns.length; i++) {
      final c = columns[i];
      final createdIdx = c.createdByMe.indexWhere((t) => t.id == taskId);
      if (createdIdx != -1) {
        return (
          c.id,
          KanbanSection.createdByMe,
          c,
          createdIdx,
          c.createdByMe[createdIdx]
        );
      }
      final assignedIdx = c.assignedToMe.indexWhere((t) => t.id == taskId);
      if (assignedIdx != -1) {
        return (
          c.id,
          KanbanSection.assignedToMe,
          c,
          assignedIdx,
          c.assignedToMe[assignedIdx]
        );
      }
    }
    return null;
  }

  static int? indexOfTaskInSection(
    List<KanbanColumn> columns,
    String columnId,
    KanbanSection section,
    String taskId,
  ) {
    final colIdx = columns.indexWhere((c) => c.id == columnId);
    if (colIdx == -1) return null;
    final list = section == KanbanSection.createdByMe
        ? columns[colIdx].createdByMe
        : columns[colIdx].assignedToMe;
    final idx = list.indexWhere((t) => t.id == taskId);
    return idx == -1 ? null : idx;
  }

  static List<KanbanColumn> moveTaskInState(
    List<KanbanColumn> columns,
    String taskId,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
    KanbanSection toSection,
    int? toIndex,
  ) {
    final fromColIdx = columns.indexWhere((c) => c.id == fromColumnId);
    if (fromColIdx == -1) return columns;
    final fromCol = columns[fromColIdx];
    final fromList = fromSection == KanbanSection.createdByMe
        ? fromCol.createdByMe
        : fromCol.assignedToMe;
    final taskIdx = fromList.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return columns;
    final task = fromList[taskIdx];
    final toColIdx = columns.indexWhere((c) => c.id == toColumnId);
    if (toColIdx == -1) return columns;
    final toCol = columns[toColIdx];
    final isSameList = fromColIdx == toColIdx && fromSection == toSection;

    if (isSameList) {
      final reorderedList = List<KanbanGroupItem>.from(fromList)
        ..removeAt(taskIdx);
      final rawInsertIdx = toIndex ?? reorderedList.length;
      final adjustedInsertIdx = (toIndex != null && rawInsertIdx > taskIdx)
          ? rawInsertIdx - 1
          : rawInsertIdx;
      final insertIdx = adjustedInsertIdx.clamp(0, reorderedList.length);
      reorderedList.insert(insertIdx, task);

      final reorderedColumn = KanbanColumn(
          id: fromCol.id,
          title: fromCol.title,
          position: fromCol.position,
          createdByMe: fromSection == KanbanSection.createdByMe
              ? reorderedList
              : fromCol.createdByMe,
          assignedToMe: fromSection == KanbanSection.assignedToMe
              ? reorderedList
              : fromCol.assignedToMe);

      return columns.asMap().entries.map((e) {
        if (e.key == fromColIdx) return reorderedColumn;
        return e.value;
      }).toList();
    }

    final updatedTask = task.copyWith(
        columnId: toColumnId,
        archivedAt: toCol.isArchive ? DateTime.now() : null);
    final newFromList = List<KanbanGroupItem>.from(fromList)..removeAt(taskIdx);
    final newFromCol = KanbanColumn(
        id: fromCol.id,
        title: fromCol.title,
        position: fromCol.position,
        createdByMe: fromSection == KanbanSection.createdByMe
            ? newFromList
            : fromCol.createdByMe,
        assignedToMe: fromSection == KanbanSection.assignedToMe
            ? newFromList
            : fromCol.assignedToMe);
    final toList = toSection == KanbanSection.createdByMe
        ? toCol.createdByMe
        : toCol.assignedToMe;
    final insertIdx =
        toIndex != null ? toIndex.clamp(0, toList.length) : toList.length;
    final newToList = List<KanbanGroupItem>.from(toList)
      ..insert(insertIdx, updatedTask);
    final newToCol = KanbanColumn(
        id: toCol.id,
        title: toCol.title,
        position: toCol.position,
        createdByMe: toSection == KanbanSection.createdByMe
            ? newToList
            : toCol.createdByMe,
        assignedToMe: toSection == KanbanSection.assignedToMe
            ? newToList
            : toCol.assignedToMe);
    return columns.asMap().entries.map((e) {
      if (e.key == fromColIdx) return newFromCol;
      if (e.key == toColIdx) return newToCol;
      return e.value;
    }).toList();
  }

  static List<KanbanColumn> updateTaskInState(
    List<KanbanColumn> columns,
    String columnId,
    KanbanSection section,
    String taskId,
    KanbanGroupItem Function(KanbanGroupItem) update,
  ) {
    return columns.map((c) {
      if (c.id != columnId) return c;
      final list =
          section == KanbanSection.createdByMe ? c.createdByMe : c.assignedToMe;
      final idx = list.indexWhere((t) => t.id == taskId);
      if (idx == -1) return c;
      final newList = List<KanbanGroupItem>.from(list)
        ..[idx] = update(list[idx]);
      return KanbanColumn(
          id: c.id,
          title: c.title,
          position: c.position,
          createdByMe:
              section == KanbanSection.createdByMe ? newList : c.createdByMe,
          assignedToMe:
              section == KanbanSection.assignedToMe ? newList : c.assignedToMe);
    }).toList();
  }
}
