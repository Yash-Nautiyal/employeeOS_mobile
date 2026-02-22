import 'dart:typed_data';

enum KanbanSection { createdByMe, assignedToMe }

class KanbanSubtask {
  final String id;
  final String name;
  final bool completed;

  const KanbanSubtask({
    required this.id,
    required this.name,
    required this.completed,
  });

  KanbanSubtask copyWith({String? id, String? name, bool? completed}) {
    return KanbanSubtask(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }

  factory KanbanSubtask.fromJson(Map<String, dynamic> json) {
    return KanbanSubtask(
      id: json['id'] as String,
      name: json['name'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class KanbanAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;

  const KanbanAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedBy,
  });

  KanbanAttachment copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? uploadedBy,
  }) {
    return KanbanAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }

  factory KanbanAttachment.fromJson(Map<String, dynamic> json) {
    return KanbanAttachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadedBy: json['uploaded_by'] as String?,
    );
  }
}

class KanbanUploadFile {
  final String fileName;
  final Uint8List bytes;
  final String? fileType;
  final int fileSize;

  const KanbanUploadFile({
    required this.fileName,
    required this.bytes,
    this.fileType,
    required this.fileSize,
  });
}

class KanbanAssignee {
  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;

  const KanbanAssignee({
    required this.userId,
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

  factory KanbanAssignee.fromJson(Map<String, dynamic> json) {
    return KanbanAssignee(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  KanbanAssignee copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return KanbanAssignee(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class KanbanGroupItem {
  static const Object _unset = Object();

  final String itemId;
  final String title;
  final String columnId;
  final KanbanAssignee? reporter;
  final List<KanbanAssignee> assignees;
  final DateTime? dueStart;
  final DateTime? dueEnd;
  final String priority;
  final String description;
  final List<KanbanAttachment> attachments;
  final List<KanbanSubtask> subtasks;
  final int? subtaskTotal;
  final int? subtaskCompleted;
  final DateTime? archivedAt;
  final DateTime createdAt;

  const KanbanGroupItem({
    required this.itemId,
    required this.title,
    required this.columnId,
    this.reporter,
    required this.assignees,
    this.dueStart,
    this.dueEnd,
    required this.priority,
    required this.description,
    required this.attachments,
    required this.subtasks,
    this.subtaskTotal,
    this.subtaskCompleted,
    this.archivedAt,
    required this.createdAt,
  });

  String get id => itemId;

  int get completedTasks =>
      subtaskCompleted ?? subtasks.where((s) => s.completed).length;
  int get totalTasks => subtaskTotal ?? subtasks.length;

  bool get isOverdue =>
      dueEnd != null && DateTime.now().isAfter(dueEnd!) && archivedAt == null;

  bool get allSubtasksComplete =>
      subtasks.isEmpty || subtasks.every((s) => s.completed);

  String get assignedToLabel =>
      assignees.isEmpty ? 'Unassigned' : assignees.first.name;

  String get displayDate => formatDueDateRange(dueStart, dueEnd);

  static String formatDueDateRange(DateTime? dueStart, DateTime? dueEnd) {
    if (dueStart == null && dueEnd == null) return '';
    if (dueStart == null) return _formatDate(dueEnd!);
    if (dueEnd == null) return '${_formatDate(dueStart)} - ...';

    final start = _dateOnly(dueStart);
    final end = _dateOnly(dueEnd);
    final rangeStart = start.isAfter(end) ? end : start;
    final rangeEnd = start.isAfter(end) ? start : end;

    if (_isSameDay(rangeStart, rangeEnd)) {
      return _formatDate(rangeStart);
    }
    if (rangeStart.year != rangeEnd.year) {
      return '${_formatDate(rangeStart, includeYear: true)} - '
          '${_formatDate(rangeEnd, includeYear: true)}';
    }
    if (rangeStart.month == rangeEnd.month) {
      return '${rangeStart.day}-${rangeEnd.day} ${_monthName(rangeStart.month)}';
    }
    return '${_formatDate(rangeStart)} - ${_formatDate(rangeEnd)}';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatDate(DateTime date, {bool includeYear = false}) {
    final base = '${date.day} ${_monthName(date.month)}';
    if (!includeYear) return base;
    return '$base ${date.year}';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  factory KanbanGroupItem.fromBoardJson(
      Map<String, dynamic> json, String columnId) {
    return KanbanGroupItem(
      itemId: json['id'] as String,
      title: json['name'] as String,
      columnId: columnId,
      reporter: json['reporter'] != null
          ? KanbanAssignee.fromJson(json['reporter'] as Map<String, dynamic>)
          : null,
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((a) => KanbanAssignee.fromJson(a as Map<String, dynamic>))
          .toList(),
      dueStart: json['due_start'] != null
          ? DateTime.tryParse(json['due_start'] as String)
          : null,
      dueEnd: json['due_end'] != null
          ? DateTime.tryParse(json['due_end'] as String)
          : null,
      priority: json['priority'] as String? ?? 'medium',
      description: '',
      attachments: const [],
      subtasks: const [],
      subtaskTotal: json['subtask_total'] as int? ?? 0,
      subtaskCompleted: json['subtask_completed'] as int? ?? 0,
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory KanbanGroupItem.fromDetailJson(Map<String, dynamic> json) {
    return KanbanGroupItem(
      itemId: json['id'] as String,
      title: json['name'] as String,
      columnId: json['column_id'] as String,
      reporter: json['reporter'] != null
          ? KanbanAssignee.fromJson(json['reporter'] as Map<String, dynamic>)
          : null,
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((a) => KanbanAssignee.fromJson(a as Map<String, dynamic>))
          .toList(),
      dueStart: json['due_start'] != null
          ? DateTime.tryParse(json['due_start'] as String)
          : null,
      dueEnd: json['due_end'] != null
          ? DateTime.tryParse(json['due_end'] as String)
          : null,
      priority: json['priority'] as String? ?? 'medium',
      description: json['description'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => KanbanAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((s) => KanbanSubtask.fromJson(s as Map<String, dynamic>))
          .toList(),
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  KanbanGroupItem copyWith({
    String? itemId,
    String? title,
    String? columnId,
    KanbanAssignee? reporter,
    List<KanbanAssignee>? assignees,
    Object? dueStart = _unset,
    Object? dueEnd = _unset,
    String? priority,
    String? description,
    List<KanbanAttachment>? attachments,
    List<KanbanSubtask>? subtasks,
    int? subtaskTotal,
    int? subtaskCompleted,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) {
    return KanbanGroupItem(
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      columnId: columnId ?? this.columnId,
      reporter: reporter ?? this.reporter,
      assignees: assignees ?? this.assignees,
      dueStart: dueStart == _unset ? this.dueStart : dueStart as DateTime?,
      dueEnd: dueEnd == _unset ? this.dueEnd : dueEnd as DateTime?,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      subtasks: subtasks ?? this.subtasks,
      subtaskTotal: subtaskTotal ?? this.subtaskTotal,
      subtaskCompleted: subtaskCompleted ?? this.subtaskCompleted,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class KanbanColumn {
  final String id;
  final String title;
  final int position;
  final List<KanbanGroupItem> createdByMe;
  final List<KanbanGroupItem> assignedToMe;

  const KanbanColumn({
    required this.id,
    required this.title,
    required this.position,
    required this.createdByMe,
    required this.assignedToMe,
  });

  int get totalCount => createdByMe.length + assignedToMe.length;

  bool get isArchive => title.toLowerCase() == 'archive';

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    final columnId = json['id'] as String;
    return KanbanColumn(
      id: columnId,
      title: json['name'] as String,
      position: json['position'] as int? ?? 0,
      createdByMe: (json['created_by_me'] as List<dynamic>? ?? [])
          .map((t) => KanbanGroupItem.fromBoardJson(
              t as Map<String, dynamic>, columnId))
          .toList(),
      assignedToMe: (json['assigned_to_me'] as List<dynamic>? ?? [])
          .map((t) => KanbanGroupItem.fromBoardJson(
              t as Map<String, dynamic>, columnId))
          .toList(),
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
