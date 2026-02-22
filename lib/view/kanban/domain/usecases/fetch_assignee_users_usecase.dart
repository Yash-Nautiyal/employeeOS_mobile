import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class FetchAssigneeUsersUseCase {
  final KanbanRepository _repository;
  const FetchAssigneeUsersUseCase(this._repository);

  Future<List<KanbanAssignee>> call() {
    return _repository.fetchUsersForAssignees();
  }
}
