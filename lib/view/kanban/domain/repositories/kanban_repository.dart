import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';

/// Abstraction for Kanban data source.
///
/// For now we keep it simple and synchronous with in-memory data so the backend
/// team can later plug in async/database calls behind the same interface.
abstract class KanbanRepository {
  List<KanbanColumn> loadBoard();

  List<KanbanColumn> addColumn(String title);
  List<KanbanColumn> renameColumn(String columnId, String newTitle);
  List<KanbanColumn> clearColumn(String columnId);
  List<KanbanColumn> deleteColumn(String columnId);

  List<KanbanColumn> addTask({
    required String columnId,
    required KanbanGroupItem task,
    required KanbanSection section,
  });

  List<KanbanColumn> updatePriority({
    required String columnId,
    required KanbanSection section,
    required String taskId,
    required String priority,
  });

  List<KanbanColumn> updateAssignees({
    required String columnId,
    required KanbanSection section,
    required String taskId,
    required List<KanbanAssignee> assignees,
  });

  List<KanbanColumn> moveTask({
    required DragPayload payload,
    required String toColumnId,
    required KanbanSection toSection,
    required int toIndex,
  });

  List<KanbanColumn> moveTaskToColumn({
    required KanbanGroupItem task,
    required String fromColumnId,
    required KanbanSection fromSection,
    required String toColumnId,
  });
}
