import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';

/// Repository for Kanban board and tasks.
/// All methods are async and may throw on failure.
abstract class KanbanRepository {
  /// Load full board for current user. Throws on error.
  Future<List<KanbanColumn>> loadBoard();

  /// Create column. Returns new column id and position.
  Future<Map<String, dynamic>> createColumn(String name);

  Future<void> renameColumn(String columnId, String newTitle);

  /// Clear tasks created by current user in column. Returns deleted count.
  Future<int> clearColumn(String columnId);

  Future<void> deleteColumn(String columnId);

  /// Reorder columns. positions: list of { id, position }.
  Future<void> reorderColumns(List<Map<String, dynamic>> positions);

  /// Create task with name only. Returns created task row (id, name, created_at).
  Future<Map<String, dynamic>> createTask(String columnId, String name);

  /// Full task detail. Throws if not found.
  Future<KanbanGroupItem> getTaskDetail(String taskId);

  /// Upload one or many attachments and create DB records.
  Future<List<KanbanAttachment>> uploadAttachments({
    required String taskId,
    required List<KanbanUploadFile> files,
  });

  /// Delete a task attachment. Only uploader is allowed.
  Future<void> deleteAttachment(String attachmentId);

  /// Update task fields. Only include keys that changed.
  Future<void> updateTask(String taskId, Map<String, dynamic> updates);

  /// Move task to column. Returns { success: bool, error?: string }.
  Future<Map<String, dynamic>> moveTaskToColumn({
    required String taskId,
    required String targetColumnId,
  });

  /// Mark task complete (moves to Archive). Returns { success, error? }.
  Future<Map<String, dynamic>> markTaskComplete(String taskId);

  /// Delete task. Returns { success, error? }. Only creator can delete.
  Future<Map<String, dynamic>> deleteTask(String taskId);

  Future<void> addAssignee(String taskId, String userId);

  Future<void> removeAssignee(String taskId, String userId);

  /// Add subtask. Returns { id, name, completed }.
  Future<Map<String, dynamic>> addSubtask(String taskId, String name);

  Future<void> updateSubtaskCompleted(String subtaskId, bool completed);

  Future<void> updateSubtaskName(String subtaskId, String name);

  Future<void> deleteSubtask(String subtaskId);

  /// Current user as assignee (for new tasks). Null if not logged in.
  Future<KanbanAssignee?> getCurrentUserAssignee();

  /// All users for assignee picker (uses core UserInfoService).
  Future<List<KanbanAssignee>> fetchUsersForAssignees();
}
