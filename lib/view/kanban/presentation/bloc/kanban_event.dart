import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:equatable/equatable.dart';

abstract class KanbanEvent extends Equatable {
  const KanbanEvent();

  @override
  List<Object?> get props => [];
}

class KanbanLoadRequested extends KanbanEvent {
  const KanbanLoadRequested();
}

class KanbanColumnAdded extends KanbanEvent {
  final String title;
  const KanbanColumnAdded(this.title);
  @override
  List<Object?> get props => [title];
}

class KanbanColumnRenamed extends KanbanEvent {
  final String columnId;
  final String newTitle;
  const KanbanColumnRenamed(this.columnId, this.newTitle);
  @override
  List<Object?> get props => [columnId, newTitle];
}

class KanbanColumnDeleted extends KanbanEvent {
  final String columnId;
  const KanbanColumnDeleted(this.columnId);
  @override
  List<Object?> get props => [columnId];
}

class KanbanColumnCleared extends KanbanEvent {
  final String columnId;
  const KanbanColumnCleared(this.columnId);
  @override
  List<Object?> get props => [columnId];
}

class KanbanTaskAdded extends KanbanEvent {
  final String columnId;
  final KanbanSection section;
  final KanbanGroupItem task;
  const KanbanTaskAdded({
    required this.columnId,
    required this.section,
    required this.task,
  });
  @override
  List<Object?> get props => [columnId, section, task];
}

class KanbanTaskMoved extends KanbanEvent {
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

class KanbanTaskMovedToColumn extends KanbanEvent {
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

class KanbanTaskPriorityChanged extends KanbanEvent {
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

class KanbanTaskAssigneesUpdated extends KanbanEvent {
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