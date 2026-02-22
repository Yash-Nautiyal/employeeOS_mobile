part of 'kanban_bloc.dart';

extension KanbanLoadDetailHandlers on KanbanBloc {
  Future<void> _onLoad(
      KanbanLoadRequested event, Emitter<KanbanState> emit) async {
    emit(KanbanLoading());
    try {
      final columns = await _loadBoardUseCase();
      emit(KanbanLoaded(columns));
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
      emit(KanbanError(e.toString()));
    }
  }

  Future<void> _onUsersForAssigneesRequested(
      KanbanUsersForAssigneesRequested event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    if (current.usersForAssignees != null) return;
    emit(current.copyWith(isLoadingUsersForAssignees: true));
    try {
      final users = await _fetchAssigneeUsersUseCase();
      emit(current.copyWith(
          usersForAssignees: users, isLoadingUsersForAssignees: false));
    } catch (e) {
      emit(current.copyWith(isLoadingUsersForAssignees: false));
    }
  }
}
