import 'package:employeeos/core/user/user_info_index.dart';
import 'package:employeeos/view/kanban/data/datasources/kanban_remote_datasource.dart';
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

/// Supabase-backed implementation of [KanbanRepository].
/// Uses [UserInfoService] for mapping user ids to assignees when needed.
class KanbanRepositoryImpl implements KanbanRepository {
  KanbanRepositoryImpl({
    KanbanRemoteDatasource? datasource,
    UserInfoService? userInfoService,
  })  : _datasource = datasource ?? KanbanRemoteDatasource(),
        _userInfoService = userInfoService ?? UserInfoService();

  final KanbanRemoteDatasource _datasource;
  final UserInfoService _userInfoService;

  @override
  Future<List<KanbanColumn>> loadBoard() async {
    return _datasource.getKanbanBoard();
  }

  @override
  Future<Map<String, dynamic>> createColumn(String name) async {
    return _datasource.createColumn(name);
  }

  @override
  Future<void> renameColumn(String columnId, String newTitle) async {
    return _datasource.renameColumn(columnId, newTitle);
  }

  @override
  Future<int> clearColumn(String columnId) async {
    return _datasource.clearColumn(columnId);
  }

  @override
  Future<void> deleteColumn(String columnId) async {
    return _datasource.deleteColumn(columnId);
  }

  @override
  Future<void> reorderColumns(List<Map<String, dynamic>> positions) async {
    return _datasource.reorderColumns(positions);
  }

  @override
  Future<Map<String, dynamic>> createTask(String columnId, String name) async {
    return _datasource.createTask(columnId, name);
  }

  @override
  Future<KanbanGroupItem> getTaskDetail(String taskId) async {
    final json = await _datasource.getTaskDetail(taskId);
    return KanbanGroupItem.fromDetailJson(json);
  }

  @override
  Future<List<KanbanAttachment>> uploadAttachments({
    required String taskId,
    required List<KanbanUploadFile> files,
  }) async {
    final rows =
        await _datasource.uploadAttachments(taskId: taskId, files: files);
    return rows.map(KanbanAttachment.fromJson).toList();
  }

  @override
  Future<void> deleteAttachment(String attachmentId) {
    return _datasource.deleteAttachment(attachmentId);
  }

  @override
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    return _datasource.updateTask(taskId, updates);
  }

  @override
  Future<Map<String, dynamic>> moveTaskToColumn({
    required String taskId,
    required String targetColumnId,
  }) async {
    return _datasource.moveTaskToColumn(
      taskId: taskId,
      targetColumnId: targetColumnId,
    );
  }

  @override
  Future<Map<String, dynamic>> markTaskComplete(String taskId) async {
    return _datasource.markTaskComplete(taskId);
  }

  @override
  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    return _datasource.deleteTask(taskId);
  }

  @override
  Future<void> addAssignee(String taskId, String userId) async {
    return _datasource.addAssignee(taskId, userId);
  }

  @override
  Future<void> removeAssignee(String taskId, String userId) async {
    return _datasource.removeAssignee(taskId, userId);
  }

  @override
  Future<Map<String, dynamic>> addSubtask(String taskId, String name) async {
    return _datasource.addSubtask(taskId, name);
  }

  @override
  Future<void> updateSubtaskCompleted(String subtaskId, bool completed) async {
    return _datasource.updateSubtaskCompleted(subtaskId, completed);
  }

  @override
  Future<void> updateSubtaskName(String subtaskId, String name) async {
    return _datasource.updateSubtaskName(subtaskId, name);
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    return _datasource.deleteSubtask(subtaskId);
  }

  /// Fetch all users (for assignee picker). Uses core [UserInfoService].
  @override
  Future<List<KanbanAssignee>> fetchUsersForAssignees() async {
    final entities = await _userInfoService.fetchAllUsers();
    return entities.map(_entityToAssignee).toList();
  }

  /// Current user as [KanbanAssignee] for new tasks. Returns null if not logged in.
  @override
  Future<KanbanAssignee?> getCurrentUserAssignee() async {
    final userId = _datasource.currentUserId;
    if (userId == null) return null;
    final entity = await _userInfoService.fetchUserById(userId);
    if (entity == null) return null;
    return _entityToAssignee(entity);
  }

  KanbanAssignee _entityToAssignee(UserInfoEntity e) {
    return KanbanAssignee(
      userId: e.id,
      name: e.fullName.isNotEmpty ? e.fullName : 'Unknown',
      email: e.email,
      avatarUrl: e.avatarUrl,
    );
  }
}
