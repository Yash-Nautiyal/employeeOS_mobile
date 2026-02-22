import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class DeleteColumnUseCase {
  final KanbanRepository _repository;
  const DeleteColumnUseCase(this._repository);

  Future<void> call(String columnId) {
    return _repository.deleteColumn(columnId);
  }
}
