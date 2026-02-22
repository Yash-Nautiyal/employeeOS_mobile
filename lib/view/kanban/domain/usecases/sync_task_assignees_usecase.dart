import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class SyncTaskAssigneesUseCase {
  final KanbanRepository _repository;
  const SyncTaskAssigneesUseCase(this._repository);

  Future<void> call({
    required String taskId,
    required List<KanbanAssignee> currentAssignees,
    required List<KanbanAssignee> newAssignees,
  }) async {
    final currentIds = currentAssignees.map((a) => a.userId).toSet();
    final newIds = newAssignees.map((a) => a.userId).toSet();
    final toAdd = newIds.difference(currentIds);
    final toRemove = currentIds.difference(newIds);

    for (final userId in toAdd) {
      await _repository.addAssignee(taskId, userId);
    }
    for (final userId in toRemove) {
      await _repository.removeAssignee(taskId, userId);
    }
  }
}
