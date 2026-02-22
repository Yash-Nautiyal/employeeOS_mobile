import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

/// Remote data source for Kanban using Supabase RPC and tables.
/// Follows FRONTEND_GUIDE action→query mapping.
class KanbanRemoteDatasource {
  KanbanRemoteDatasource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  void _requireUser() {
    if (_userId == null) {
      throw Exception('Kanban requires an authenticated user');
    }
  }

  /// Load full board for current user.
  Future<List<KanbanColumn>> getKanbanBoard() async {
    _requireUser();
    final res = await _client.rpc(
      'get_kanban_board',
      params: {'p_user_id': _userId},
    );
    final list = res is List ? res : (res != null ? [res] : <dynamic>[]);
    return list
        .map((c) => KanbanColumn.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Create a new column. Returns id and position.
  Future<Map<String, dynamic>> createColumn(String name) async {
    final res = await _client.rpc(
      'create_column',
      params: {'p_name': name},
    );
    return res as Map<String, dynamic>;
  }

  /// Rename column. Guard: do not rename Archive.
  Future<void> renameColumn(String columnId, String newName) async {
    await _client
        .from('kanban_columns')
        .update({'name': newName}).eq('id', columnId);
  }

  /// Delete column (cascade deletes tasks). Guard: block Archive.
  Future<void> deleteColumn(String columnId) async {
    await _client.rpc('delete_column', params: {'p_column_id': columnId});
  }

  /// Clear column: only deletes tasks where reporter_id = current user.
  Future<int> clearColumn(String columnId) async {
    _requireUser();
    final res = await _client.rpc('clear_column', params: {
      'p_column_id': columnId,
      'p_user_id': _userId,
    });
    final map = res as Map<String, dynamic>?;
    return map?['deleted_count'] as int? ?? 0;
  }

  /// Reorder columns. p_positions: [ { id, position }, ... ].
  Future<void> reorderColumns(List<Map<String, dynamic>> positions) async {
    await _client.rpc('reorder_columns', params: {'p_positions': positions});
  }

  /// Create task. Returns task row with id, name, created_at.
  Future<Map<String, dynamic>> createTask(String columnId, String name) async {
    _requireUser();
    final res = await _client
        .from('kanban_tasks')
        .insert({
          'name': name,
          'column_id': columnId,
          'reporter_id': _userId,
        })
        .select('id, name, created_at')
        .single();
    return res;
  }

  /// Full task detail (subtasks, attachments, assignees, reporter).
  Future<Map<String, dynamic>> getTaskDetail(String taskId) async {
    final res =
        await _client.rpc('get_task_detail', params: {'p_task_id': taskId});
    return res as Map<String, dynamic>;
  }

  /// Update task fields (name, description, priority, due_start, due_end).
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await _client.from('kanban_tasks').update(updates).eq('id', taskId);
  }

  /// Move task to another column. Returns { success, error? }.
  Future<Map<String, dynamic>> moveTaskToColumn({
    required String taskId,
    required String targetColumnId,
  }) async {
    _requireUser();
    final res = await _client.rpc('move_task_to_column', params: {
      'p_task_id': taskId,
      'p_column_id': targetColumnId,
      'p_user_id': _userId,
    });
    return res as Map<String, dynamic>;
  }

  /// Mark task complete (moves to Archive). Returns { success, error? }.
  Future<Map<String, dynamic>> markTaskComplete(String taskId) async {
    _requireUser();
    final res = await _client.rpc('mark_task_complete', params: {
      'p_task_id': taskId,
      'p_user_id': _userId,
    });
    return res as Map<String, dynamic>;
  }

  /// Delete task. Only creator can delete. Returns { success, error? }.
  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    _requireUser();
    final res = await _client.rpc('delete_task', params: {
      'p_task_id': taskId,
      'p_user_id': _userId,
    });
    return res as Map<String, dynamic>;
  }

  /// Add assignee to task.
  Future<void> addAssignee(String taskId, String userId) async {
    await _client.from('kanban_task_assignees').insert({
      'task_id': taskId,
      'user_id': userId,
    });
  }

  /// Remove assignee from task.
  Future<void> removeAssignee(String taskId, String userId) async {
    await _client
        .from('kanban_task_assignees')
        .delete()
        .eq('task_id', taskId)
        .eq('user_id', userId);
  }

  /// Add subtask. Returns inserted row.
  Future<Map<String, dynamic>> addSubtask(String taskId, String name) async {
    final res = await _client
        .from('kanban_task_subtasks')
        .insert({'task_id': taskId, 'name': name})
        .select('id, name, completed')
        .single();
    return res;
  }

  /// Toggle subtask completed.
  Future<void> updateSubtaskCompleted(String subtaskId, bool completed) async {
    await _client
        .from('kanban_task_subtasks')
        .update({'completed': completed}).eq('id', subtaskId);
  }

  /// Update subtask name.
  Future<void> updateSubtaskName(String subtaskId, String name) async {
    await _client
        .from('kanban_task_subtasks')
        .update({'name': name}).eq('id', subtaskId);
  }

  /// Delete subtask.
  Future<void> deleteSubtask(String subtaskId) async {
    await _client.from('kanban_task_subtasks').delete().eq('id', subtaskId);
  }

  /// Insert attachment record (after uploading file to storage).
  Future<Map<String, dynamic>> insertAttachment({
    required String taskId,
    required String fileName,
    required String fileUrl,
    String? fileType,
    int? fileSize,
  }) async {
    _requireUser();
    final res = await _client
        .from('kanban_task_attachments')
        .insert({
          'task_id': taskId,
          'file_name': fileName,
          'file_url': fileUrl,
          'file_type': fileType,
          'file_size': fileSize,
          'uploaded_by': _userId,
        })
        .select()
        .single();
    return res;
  }

  /// Uploads one or many files to storage, then inserts attachment rows.
  Future<List<Map<String, dynamic>>> uploadAttachments({
    required String taskId,
    required List<KanbanUploadFile> files,
  }) async {
    if (files.isEmpty) return const [];
    final uploaded = <Map<String, dynamic>>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final safeName =
          file.fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath =
          '$taskId/${DateTime.now().millisecondsSinceEpoch}_${i}_$safeName';
      await _client.storage.from(attachmentsBucket).uploadBinary(
            storagePath,
            Uint8List.fromList(file.bytes),
            fileOptions: FileOptions(
              contentType: file.fileType ?? 'application/octet-stream',
              upsert: false,
            ),
          );
      final publicUrl =
          _client.storage.from(attachmentsBucket).getPublicUrl(storagePath);
      final row = await insertAttachment(
        taskId: taskId,
        fileName: file.fileName,
        fileUrl: publicUrl,
        fileType: file.fileType,
        fileSize: file.fileSize,
      );
      uploaded.add(row);
    }
    return uploaded;
  }

  /// Delete attachment (caller should remove from storage first if needed).
  Future<void> deleteAttachment(String attachmentId) async {
    _requireUser();
    final userId = _userId!;
    final row = await _client
        .from('kanban_task_attachments')
        .select('id, file_url, uploaded_by')
        .eq('id', attachmentId)
        .maybeSingle();
    if (row == null) {
      throw Exception('Attachment not found');
    }
    final uploadedBy = row['uploaded_by'] as String?;
    if (uploadedBy == null || uploadedBy != userId) {
      throw Exception('Only uploader can delete this attachment');
    }
    final fileUrl = row['file_url'] as String?;
    final storagePath = _extractStoragePath(fileUrl);
    if (storagePath != null && storagePath.isNotEmpty) {
      await _client.storage.from(attachmentsBucket).remove([storagePath]);
    }
    await _client
        .from('kanban_task_attachments')
        .delete()
        .eq('id', attachmentId)
        .eq('uploaded_by', userId);
  }

  String? _extractStoragePath(String? publicUrl) {
    if (publicUrl == null || publicUrl.isEmpty) return null;
    final marker = '/storage/v1/object/public/$attachmentsBucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return publicUrl.substring(idx + marker.length);
  }

  /// Storage bucket for attachments.
  String get attachmentsBucket => 'kanban-attachments';

  /// Current authenticated user id, or null.
  String? get currentUserId => _userId;
}
