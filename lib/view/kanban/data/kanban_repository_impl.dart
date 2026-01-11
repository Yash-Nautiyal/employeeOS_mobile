import 'package:employeeos/view/kanban/data/test_data.dart';
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';
import 'package:uuid/uuid.dart';

/// Simple in-memory implementation using the existing test_data map.
///
/// All methods return a new List<KanbanColumn> so callers can treat data as
/// immutable snapshots. Deep copies are created for columns/tasks that change.
class InMemoryKanbanRepository implements KanbanRepository {
  final Uuid _uuid = const Uuid();

  /// Internal mutable store.
  final List<KanbanColumn> _columns = _seedFromData();

  static List<KanbanColumn> _seedFromData() {
    return kanbanData.entries.map((entry) {
      final title = entry.key;
      final rawItems = (entry.value['items'] as List?) ?? const [];
      final tasks = rawItems.map<KanbanGroupItem>((item) {
        final tasksStr = (item['tasks'] ?? '0/0').toString();
        final parts = tasksStr.split('/');
        final completed = int.tryParse(parts.first.trim()) ?? 0;
        final total =
            int.tryParse(parts.length > 1 ? parts.last.trim() : '0') ?? 0;
        final rawAssignees = (item['assignees'] as List?) ?? [];
        final assignees = rawAssignees.isNotEmpty
            ? rawAssignees.map<KanbanAssignee>((a) {
                final name = (a['name'] ?? '').toString();
                return KanbanAssignee(
                  name: name,
                  email: (a['email'] ?? '').toString(),
                  avatarUrl: a['avatarUrl']?.toString(),
                );
              }).toList()
            : [
                KanbanAssignee(
                  name: (item['assignedTo'] ?? 'Unknown').toString(),
                  email:
                      '${(item['assignedTo'] ?? 'unknown').toString().replaceAll(' ', '.').toLowerCase()}@example.com',
                )
              ];
        return KanbanGroupItem(
          itemId: const Uuid().v4().toString(),
          title: (item['title'] ?? '').toString(),
          date: (item['date'] ?? '').toString(),
          completedTasks: completed,
          totalTasks: total,
          assignedBy: (item['assignedBy'] ?? 'Unknown').toString(),
          assignees: assignees,
          dueDate: (item['dueDate'] ?? '').toString(),
          priority: (item['priority'] ?? 'Low').toString(),
          description: (item['description'] ?? '').toString(),
          attachments: List<String>.from(item['attachments'] ?? const []),
          subtasks: Map<String, bool>.from(item['subtasks'] ?? const {}),
        );
      }).toList();

      final createdByMe = <KanbanGroupItem>[];
      final assignedToMe = <KanbanGroupItem>[];
      // Simple split based on assignedBy; keeps others visible in assignedToMe.
      for (final t in tasks) {
        if (t.assignedBy == 'Shreyas Ladhe') {
          createdByMe.add(t);
        } else if (t.assignees
            .any((a) => a.name.toLowerCase() == 'shreyas ladhe')) {
          assignedToMe.add(t);
        } else {
          assignedToMe.add(t);
        }
      }

      return KanbanColumn(
        id: title,
        title: title,
        createdByMe: createdByMe,
        assignedToMe: assignedToMe,
      );
    }).toList();
  }

  List<KanbanColumn> _snapshot() => _columns
      .map((c) => KanbanColumn(
            id: c.id,
            title: c.title,
            createdByMe: c.createdByMe.map(_cloneTask).toList(),
            assignedToMe: c.assignedToMe.map(_cloneTask).toList(),
          ))
      .toList();

  KanbanGroupItem _cloneTask(KanbanGroupItem task) => KanbanGroupItem(
        itemId: task.itemId,
        title: task.title,
        date: task.date,
        completedTasks: task.completedTasks,
        totalTasks: task.totalTasks,
        assignedBy: task.assignedBy,
        assignees: task.assignees.map((a) => a.copyWith()).toList(),
        dueDate: task.dueDate,
        priority: task.priority,
        description: task.description,
        attachments: List<String>.from(task.attachments),
        subtasks: Map<String, bool>.from(task.subtasks),
      );

  KanbanColumn? _findColumn(String id) {
    try {
      return _columns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<KanbanColumn> loadBoard() => _snapshot();

  @override
  List<KanbanColumn> addColumn(String title) {
    _columns.add(KanbanColumn(
        id: title,
        title: title,
        createdByMe: const [],
        assignedToMe: const []));
    return _snapshot();
  }

  @override
  List<KanbanColumn> renameColumn(String columnId, String newTitle) {
    final idx = _columns.indexWhere((c) => c.id == columnId);
    if (idx != -1) {
      final c = _columns[idx];
      _columns[idx] = KanbanColumn(
        id: newTitle,
        title: newTitle,
        createdByMe: c.createdByMe,
        assignedToMe: c.assignedToMe,
      );
    }
    return _snapshot();
  }

  @override
  List<KanbanColumn> clearColumn(String columnId) {
    final idx = _columns.indexWhere((c) => c.id == columnId);
    if (idx != -1) {
      final c = _columns[idx];
      _columns[idx] = KanbanColumn(
        id: c.id,
        title: c.title,
        createdByMe: const [],
        assignedToMe: const [],
      );
    }
    return _snapshot();
  }

  @override
  List<KanbanColumn> deleteColumn(String columnId) {
    _columns.removeWhere((c) => c.id == columnId);
    return _snapshot();
  }

  @override
  List<KanbanColumn> addTask({
    required String columnId,
    required KanbanGroupItem task,
    required KanbanSection section,
  }) {
    final idx = _columns.indexWhere((c) => c.id == columnId);
    if (idx != -1) {
      final c = _columns[idx];
      final created = List<KanbanGroupItem>.from(c.createdByMe);
      final assigned = List<KanbanGroupItem>.from(c.assignedToMe);
      final withId = task.copyWith(itemId: _uuid.v4());
      if (section == KanbanSection.createdByMe) {
        created.add(withId);
      } else {
        assigned.add(withId);
      }
      _columns[idx] = KanbanColumn(
        id: c.id,
        title: c.title,
        createdByMe: created,
        assignedToMe: assigned,
      );
    }
    return _snapshot();
  }

  @override
  List<KanbanColumn> updatePriority({
    required String columnId,
    required KanbanSection section,
    required String taskId,
    required String priority,
  }) {
    final column = _findColumn(columnId);
    if (column == null) return _snapshot();
    final list = section == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(column.createdByMe)
        : List<KanbanGroupItem>.from(column.assignedToMe);
    final idx = list.indexWhere((t) => t.id == taskId);
    if (idx == -1) return _snapshot();
    list[idx] = list[idx].copyWith(priority: priority);
    _replaceColumn(column, list, section);
    return _snapshot();
  }

  @override
  List<KanbanColumn> updateAssignees({
    required String columnId,
    required KanbanSection section,
    required String taskId,
    required List<KanbanAssignee> assignees,
  }) {
    final column = _findColumn(columnId);
    if (column == null) return _snapshot();
    final list = section == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(column.createdByMe)
        : List<KanbanGroupItem>.from(column.assignedToMe);
    final idx = list.indexWhere((t) => t.id == taskId);
    if (idx == -1) return _snapshot();
    list[idx] = list[idx].copyWith(
        assignees: assignees.map((a) => a.copyWith()).toList());
    _replaceColumn(column, list, section);
    return _snapshot();
  }

  @override
  List<KanbanColumn> moveTask({
    required DragPayload payload,
    required String toColumnId,
    required KanbanSection toSection,
    required int toIndex,
  }) {
    final fromCol = _findColumn(payload.fromColumn);
    final toCol = _findColumn(toColumnId);
    if (fromCol == null || toCol == null) return _snapshot();

    final fromList = payload.fromSection == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(fromCol.createdByMe)
        : List<KanbanGroupItem>.from(fromCol.assignedToMe);
    final toList = toSection == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(toCol.createdByMe)
        : List<KanbanGroupItem>.from(toCol.assignedToMe);

    final fromIndex = fromList.indexWhere((t) => t.id == payload.task.id);
    if (fromIndex == -1) return _snapshot();
    final moved = fromList.removeAt(fromIndex);

    var insertIndex = toIndex.clamp(0, toList.length);
    if (identical(fromList, toList) && toIndex > fromIndex) {
      insertIndex = (insertIndex - 1).clamp(0, toList.length);
    }
    toList.insert(insertIndex, moved);

    _replaceColumn(fromCol, fromList, payload.fromSection);
    _replaceColumn(toCol, toList, toSection);
    return _snapshot();
  }

  @override
  List<KanbanColumn> moveTaskToColumn({
    required KanbanGroupItem task,
    required String fromColumnId,
    required KanbanSection fromSection,
    required String toColumnId,
  }) {
    final fromCol = _findColumn(fromColumnId);
    final toCol = _findColumn(toColumnId);
    if (fromCol == null || toCol == null) return _snapshot();

    final fromList = fromSection == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(fromCol.createdByMe)
        : List<KanbanGroupItem>.from(fromCol.assignedToMe);
    final toList = fromSection == KanbanSection.createdByMe
        ? List<KanbanGroupItem>.from(toCol.createdByMe)
        : List<KanbanGroupItem>.from(toCol.assignedToMe);

    final fromIndex = fromList.indexWhere((t) => t.id == task.id);
    if (fromIndex == -1) return _snapshot();
    final moved = fromList.removeAt(fromIndex);
    toList.add(moved);

    _replaceColumn(fromCol, fromList, fromSection);
    _replaceColumn(toCol, toList, fromSection);
    return _snapshot();
  }

  void _replaceColumn(KanbanColumn original, List<KanbanGroupItem> newList,
      KanbanSection section) {
    final idx = _columns.indexWhere((c) => c.id == original.id);
    if (idx == -1) return;
    _columns[idx] = KanbanColumn(
      id: original.id,
      title: original.title,
      createdByMe:
          section == KanbanSection.createdByMe ? newList : original.createdByMe,
      assignedToMe: section == KanbanSection.assignedToMe
          ? newList
          : original.assignedToMe,
    );
  }
}
