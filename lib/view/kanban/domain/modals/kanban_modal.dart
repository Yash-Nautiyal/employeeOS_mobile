enum KanbanSection { createdByMe, assignedToMe }

class KanbanAssignee {
  final String name;
  final String email;
  final String? avatarUrl;

  const KanbanAssignee({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  KanbanAssignee copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return KanbanAssignee(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

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
  final List<KanbanAssignee> assignees;
  final String dueDate;
  final String priority;
  final String description;
  final List<String> attachments;
  final Map<String, bool> subtasks;

  const KanbanGroupItem({
    required this.itemId,
    required this.title,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.assignedBy,
    required this.assignees,
    required this.dueDate,
    required this.priority,
    required this.description,
    required this.attachments,
    required this.subtasks,
  });

  String get id => itemId;

  String get assignedToLabel =>
      assignees.isEmpty ? 'Unassigned' : assignees.first.name;

  KanbanGroupItem copyWith({
    String? itemId,
    String? title,
    String? date,
    int? completedTasks,
    int? totalTasks,
    String? assignedBy,
    List<KanbanAssignee>? assignees,
    String? dueDate,
    String? priority,
    String? description,
    List<String>? attachments,
    Map<String, bool>? subtasks,
  }) {
    return KanbanGroupItem(
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      date: date ?? this.date,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      assignedBy: assignedBy ?? this.assignedBy,
      assignees: assignees ?? this.assignees,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      subtasks: subtasks ?? this.subtasks,
    );
  }
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
