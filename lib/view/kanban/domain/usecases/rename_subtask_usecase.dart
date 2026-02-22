import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class RenameSubtaskUseCase {
  final KanbanRepository _repository;
  const RenameSubtaskUseCase(this._repository);

  Future<void> call({
    required String subtaskId,
    required String name,
  }) {
    return _repository.updateSubtaskName(subtaskId, name);
  }
}
