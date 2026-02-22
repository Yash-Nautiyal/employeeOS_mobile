import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class DeleteSubtaskUseCase {
  final KanbanRepository _repository;
  const DeleteSubtaskUseCase(this._repository);

  Future<void> call(String subtaskId) {
    return _repository.deleteSubtask(subtaskId);
  }
}
