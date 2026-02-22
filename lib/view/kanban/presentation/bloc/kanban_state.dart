part of 'kanban_bloc.dart';

sealed class KanbanState extends Equatable {
  const KanbanState();

  @override
  List<Object?> get props => [];
}

/// Action-only states for one-off UI feedback (toasts). Do not use for build.
sealed class KanbanActionState extends KanbanState {}

final class KanbanInitial extends KanbanState {}

final class KanbanLoading extends KanbanState {}

final class KanbanLoaded extends KanbanState {
  final List<KanbanColumn> columns;
  final bool isActionLoading;
  final List<KanbanAssignee>? usersForAssignees;
  final bool isLoadingUsersForAssignees;

  const KanbanLoaded(
    this.columns, {
    this.isActionLoading = false,
    this.usersForAssignees,
    this.isLoadingUsersForAssignees = false,
  });

  @override
  List<Object?> get props => [
        columns,
        isActionLoading,
        usersForAssignees,
        isLoadingUsersForAssignees,
      ];

  KanbanLoaded copyWith({
    List<KanbanColumn>? columns,
    bool? isActionLoading,
    List<KanbanAssignee>? usersForAssignees,
    bool? isLoadingUsersForAssignees,
  }) {
    return KanbanLoaded(
      columns ?? this.columns,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      usersForAssignees: usersForAssignees ?? this.usersForAssignees,
      isLoadingUsersForAssignees:
          isLoadingUsersForAssignees ?? this.isLoadingUsersForAssignees,
    );
  }
}

final class KanbanError extends KanbanState {
  final String message;

  const KanbanError(this.message);

  @override
  List<Object?> get props => [message];
}

final class KanbanErrorActionState extends KanbanActionState {
  final String message;

  KanbanErrorActionState(this.message);

  @override
  List<Object?> get props => [message];
}

final class KanbanSuccessActionState extends KanbanActionState {
  final String message;

  KanbanSuccessActionState(this.message);

  @override
  List<Object?> get props => [message];
}
