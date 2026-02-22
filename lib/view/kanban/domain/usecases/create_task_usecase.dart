import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class CreateTaskUseCase {
  final KanbanRepository _repository;
  const CreateTaskUseCase(this._repository);

  Future<KanbanGroupItem> call({
    required String columnId,
    required String taskName,
  }) async {
    final res = await _repository.createTask(columnId, taskName.trim());
    final id = res['id'] as String? ?? res['id'].toString();
    final name = res['name'] as String? ?? taskName;
    final createdAt = res['created_at'] != null
        ? DateTime.tryParse(res['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final reporter = await _repository.getCurrentUserAssignee();
    return KanbanGroupItem(
      itemId: id,
      title: name,
      columnId: columnId,
      reporter: reporter,
      assignees: const [],
      priority: 'medium',
      description: '',
      attachments: const [],
      subtasks: const [],
      subtaskTotal: 0,
      subtaskCompleted: 0,
      createdAt: createdAt,
    );
  }
}
