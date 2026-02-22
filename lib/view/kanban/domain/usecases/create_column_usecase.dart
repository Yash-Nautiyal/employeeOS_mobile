import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class CreateColumnUseCase {
  final KanbanRepository _repository;
  const CreateColumnUseCase(this._repository);

  Future<Map<String, dynamic>> call(String name) {
    return _repository.createColumn(name);
  }
}
