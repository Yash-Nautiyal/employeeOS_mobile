import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class UpdateTaskPriorityUseCase {
  final KanbanRepository _repository;
  const UpdateTaskPriorityUseCase(this._repository);

  Future<void> call({
    required String taskId,
    required String priority,
  }) {
    return _repository.updateTask(
      taskId,
      {'priority': priority.toLowerCase()},
    );
  }
}
