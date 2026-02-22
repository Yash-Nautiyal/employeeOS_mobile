import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class RenameColumnUseCase {
  final KanbanRepository _repository;
  const RenameColumnUseCase(this._repository);

  Future<void> call({
    required String columnId,
    required String newTitle,
  }) {
    return _repository.renameColumn(columnId, newTitle);
  }
}
