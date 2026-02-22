part of 'kanban_bloc.dart';

extension KanbanCacheHelpers on KanbanBloc {
  bool _isLatestMoveRequest(String taskId, int requestId) =>
      _latestMoveRequestByTask[taskId] == requestId;

  void _patchTaskCache(
    String taskId,
    KanbanGroupItem Function(KanbanGroupItem current) updater,
  ) {
    _getTaskDetailUseCase.patchCached(taskId, updater);
  }
}
