enum KanbanSection { createdByMe, assignedToMe }

class KanbanColumn {
  final String id;
  final String title;
  final List<KanbanGroupItem> createdByMe;
  final List<KanbanGroupItem> assignedToMe;

  const KanbanColumn({
    required this.id,
    required this.title,
    required this.createdByMe,
    required this.assignedToMe,
  });

  int get totalCount => createdByMe.length + assignedToMe.length;
}

class KanbanGroupItem {
  final String itemId;
  final String title;
  final String date;
  final int completedTasks;
  final int totalTasks;
  final String assignedBy;
  final String assignedTo;
  final String dueDate;
  final String priority;
  final String description;
  final List<String> attachments;
  final Map<String, bool> subtasks;

  KanbanGroupItem({
    required this.itemId,
    required this.title,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.assignedBy,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.description,
    required this.attachments,
    required this.subtasks,
  });

  String get id => itemId;
}

class DragPayload {
  final KanbanGroupItem task;
  final String fromColumn;
  final KanbanSection fromSection;

  const DragPayload({
    required this.task,
    required this.fromColumn,
    required this.fromSection,
  });
}
