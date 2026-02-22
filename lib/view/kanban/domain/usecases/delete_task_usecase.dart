import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class DeleteTaskUseCase {
  final KanbanRepository _repository;
  const DeleteTaskUseCase(this._repository);

  Future<Map<String, dynamic>> call(String taskId) {
    return _repository.deleteTask(taskId);
  }
}
