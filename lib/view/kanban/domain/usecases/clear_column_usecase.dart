import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class ClearColumnUseCase {
  final KanbanRepository _repository;
  const ClearColumnUseCase(this._repository);

  Future<int> call(String columnId) {
    return _repository.clearColumn(columnId);
  }
}
