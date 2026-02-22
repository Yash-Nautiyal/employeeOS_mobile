import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class MoveTaskUseCase {
  final KanbanRepository _repository;
  const MoveTaskUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String taskId,
    required String targetColumnId,
  }) {
    return _repository.moveTaskToColumn(
      taskId: taskId,
      targetColumnId: targetColumnId,
    );
  }
}
