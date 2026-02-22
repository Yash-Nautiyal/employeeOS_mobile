import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class ToggleSubtaskUseCase {
  final KanbanRepository _repository;
  const ToggleSubtaskUseCase(this._repository);

  Future<void> call({
    required String subtaskId,
    required bool completed,
  }) {
    return _repository.updateSubtaskCompleted(subtaskId, completed);
  }
}
