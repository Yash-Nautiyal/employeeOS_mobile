import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class LoadBoardUseCase {
  final KanbanRepository _repository;
  const LoadBoardUseCase(this._repository);

  Future<List<KanbanColumn>> call() => _repository.loadBoard();
}
