import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class AddSubtaskUseCase {
  final KanbanRepository _repository;
  const AddSubtaskUseCase(this._repository);

  Future<KanbanSubtask> call({
    required String taskId,
    required String name,
  }) async {
    final res = await _repository.addSubtask(taskId, name);
    return KanbanSubtask(
      id: res['id'] as String,
      name: res['name'] as String,
      completed: res['completed'] as bool? ?? false,
    );
  }
}
