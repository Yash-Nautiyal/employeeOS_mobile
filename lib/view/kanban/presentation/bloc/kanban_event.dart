part of 'kanban_bloc.dart';

sealed class KanbanEvent extends Equatable {
  const KanbanEvent();

  @override
  List<Object?> get props => [];
}

final class KanbanLoadRequested extends KanbanEvent {
  const KanbanLoadRequested();
}

final class KanbanUsersForAssigneesRequested extends KanbanEvent {
  const KanbanUsersForAssigneesRequested();
}

final class KanbanColumnAdded extends KanbanEvent {
  final String title;
  const KanbanColumnAdded(this.title);
  @override
  List<Object?> get props => [title];
}

final class KanbanColumnRenamed extends KanbanEvent {
  final String columnId;
  final String newTitle;
  const KanbanColumnRenamed(this.columnId, this.newTitle);
  @override
  List<Object?> get props => [columnId, newTitle];
}

final class KanbanColumnDeleted extends KanbanEvent {
  final String columnId;
  const KanbanColumnDeleted(this.columnId);
  @override
  List<Object?> get props => [columnId];
}

final class KanbanColumnCleared extends KanbanEvent {
  final String columnId;
  const KanbanColumnCleared(this.columnId);
  @override
  List<Object?> get props => [columnId];
}

final class KanbanTaskAdded extends KanbanEvent {
  final String columnId;
  final String taskName;
  const KanbanTaskAdded({
    required this.columnId,
    required this.taskName,
  });
  @override
  List<Object?> get props => [columnId, taskName];
}

final class KanbanTaskMoved extends KanbanEvent {
  final DragPayload payload;
  final String toColumnId;
  final KanbanSection toSection;
  final int toIndex;
  const KanbanTaskMoved({
    required this.payload,
    required this.toColumnId,
    required this.toSection,
    required this.toIndex,
  });
  @override
  List<Object?> get props => [payload, toColumnId, toSection, toIndex];
}

final class KanbanTaskMovedToColumn extends KanbanEvent {
  final KanbanGroupItem task;
  final String fromColumnId;
  final KanbanSection fromSection;
  final String toColumnId;
  const KanbanTaskMovedToColumn({
    required this.task,
    required this.fromColumnId,
    required this.fromSection,
    required this.toColumnId,
  });
  @override
  List<Object?> get props => [task, fromColumnId, fromSection, toColumnId];
}

final class KanbanTaskPriorityChanged extends KanbanEvent {
  final String columnId;
  final KanbanSection section;
  final String taskId;
  final String priority;
  const KanbanTaskPriorityChanged({
    required this.columnId,
    required this.section,
    required this.taskId,
    required this.priority,
  });
  @override
  List<Object?> get props => [columnId, section, taskId, priority];
}

final class KanbanTaskDescriptionUpdated extends KanbanEvent {
  final String columnId;
  final KanbanSection section;
  final String taskId;
  final String description;
  const KanbanTaskDescriptionUpdated({
    required this.columnId,
    required this.section,
    required this.taskId,
    required this.description,
  });
  @override
  List<Object?> get props => [columnId, section, taskId, description];
}

final class KanbanTaskDueDateUpdated extends KanbanEvent {
  final String columnId;
  final KanbanSection section;
  final String taskId;
  final DateTime? dueStart;
  final DateTime? dueEnd;
  const KanbanTaskDueDateUpdated({
    required this.columnId,
    required this.section,
    required this.taskId,
    required this.dueStart,
    required this.dueEnd,
  });
  @override
  List<Object?> get props => [columnId, section, taskId, dueStart, dueEnd];
}

final class KanbanTaskAssigneesUpdated extends KanbanEvent {
  final String columnId;
  final KanbanSection section;
  final String taskId;
  final List<KanbanAssignee> assignees;
  const KanbanTaskAssigneesUpdated({
    required this.columnId,
    required this.section,
    required this.taskId,
    required this.assignees,
  });
  @override
  List<Object?> get props => [columnId, section, taskId, assignees];
}

final class KanbanSubtaskAdded extends KanbanEvent {
  final String taskId;
  final String name;
  const KanbanSubtaskAdded({required this.taskId, required this.name});
  @override
  List<Object?> get props => [taskId, name];
}

final class KanbanSubtaskToggled extends KanbanEvent {
  final String taskId;
  final String subtaskId;
  final bool completed;
  const KanbanSubtaskToggled({
    required this.taskId,
    required this.subtaskId,
    required this.completed,
  });
  @override
  List<Object?> get props => [taskId, subtaskId, completed];
}

final class KanbanSubtaskRenamed extends KanbanEvent {
  final String taskId;
  final String subtaskId;
  final String name;
  const KanbanSubtaskRenamed({
    required this.taskId,
    required this.subtaskId,
    required this.name,
  });
  @override
  List<Object?> get props => [taskId, subtaskId, name];
}

final class KanbanSubtaskDeleted extends KanbanEvent {
  final String taskId;
  final String subtaskId;
  const KanbanSubtaskDeleted({
    required this.taskId,
    required this.subtaskId,
  });
  @override
  List<Object?> get props => [taskId, subtaskId];
}
