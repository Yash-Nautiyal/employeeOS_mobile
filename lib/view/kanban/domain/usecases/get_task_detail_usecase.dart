import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class GetTaskDetailUseCase {
  GetTaskDetailUseCase(
    this._repository, {
    this.cacheTtl = const Duration(seconds: 60),
  });

  final KanbanRepository _repository;
  final Duration cacheTtl;
  final Map<String, KanbanGroupItem> _cache = {};
  final Map<String, DateTime> _cacheTimes = {};

  KanbanGroupItem? getFreshCached(String taskId) {
    final task = _cache[taskId];
    final cachedAt = _cacheTimes[taskId];
    if (task == null || cachedAt == null) return null;
    if (DateTime.now().difference(cachedAt) > cacheTtl) return null;
    return task;
  }

  KanbanGroupItem? getCached(String taskId) => _cache[taskId];

  Future<KanbanGroupItem> call(String taskId) async {
    final task = await _repository.getTaskDetail(taskId);
    upsert(task);
    return task;
  }

  void upsert(KanbanGroupItem task) {
    _cache[task.id] = task;
    _cacheTimes[task.id] = DateTime.now();
  }

  void patchCached(
    String taskId,
    KanbanGroupItem Function(KanbanGroupItem current) updater,
  ) {
    final existing = _cache[taskId];
    if (existing == null) return;
    upsert(updater(existing));
  }

  void clear(String taskId) {
    _cache.remove(taskId);
    _cacheTimes.remove(taskId);
  }
}
