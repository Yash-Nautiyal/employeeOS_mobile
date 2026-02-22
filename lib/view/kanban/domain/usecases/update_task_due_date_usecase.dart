import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class UpdateTaskDueDateUseCase {
  final KanbanRepository _repository;
  const UpdateTaskDueDateUseCase(this._repository);

  Future<void> call({
    required String taskId,
    required DateTime? dueStart,
    required DateTime? dueEnd,
  }) {
    return _repository.updateTask(taskId, {
      'due_start': dueStart?.toIso8601String(),
      'due_end': dueEnd?.toIso8601String(),
    });
  }
}
