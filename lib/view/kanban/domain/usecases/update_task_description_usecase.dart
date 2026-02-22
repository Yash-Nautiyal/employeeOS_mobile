import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class UpdateTaskDescriptionUseCase {
  final KanbanRepository _repository;
  const UpdateTaskDescriptionUseCase(this._repository);

  Future<void> call({
    required String taskId,
    required String description,
  }) {
    return _repository.updateTask(taskId, {'description': description});
  }
}
