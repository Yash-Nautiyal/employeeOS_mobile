import 'dart:ui';

import 'package:kanban_board/kanban_board.dart';

class KanbanGroup {
  final String id;
  final String title;
  final Color color;

  KanbanGroup({
    required this.id,
    required this.title,
    required this.color,
  });
}

class KanbanGroupItem extends KanbanBoardGroupItem {
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
  });

  @override
  String get id => itemId;
}

Map<String, dynamic> _kanbanData = {
  'Pending': {
    'color': const Color.fromRGBO(239, 147, 148, 1),
    'items': [
      {
        'title': 'Making A New Trend In Poster',
        'date': '17 Dec 2022',
        'tasks': '30/48',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '14 - 15 Mar 2025',
        'priority': 'High',
        'description': 'Design a new poster that trends on social media.',
        'attachments': [],
      },
      {
        'title': 'Create Remarkable',
        'date': '17 Nov 2022',
        'tasks': '15/56',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '14 - 15 Mar 2025',
        'priority': 'Medium',
        'description': 'Develop a creative campaign for remarkable products.',
        'attachments': [],
      },
      // ... add more tasks as needed
    ],
  },
  'In progress': {
    'color': const Color.fromRGBO(255, 230, 168, 1),
    'items': [
      {
        'title': 'Advertising Outdoors',
        'date': '17 Dec 2022',
        'tasks': '53/70',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '20 Mar 2025',
        'priority': 'Low',
        'description': 'Outdoor advertising campaign planning.',
        'attachments': [],
      },
      // ... add more tasks as needed
    ],
  },
  'Testing': {
    'color': const Color.fromARGB(255, 235, 235, 148),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '10 Apr 2025',
        'priority': 'Medium',
        'description': 'Test new creative designs for outdoor ads.',
        'attachments': [],
      },
    ],
  },
  'Done': {
    'color': const Color.fromRGBO(148, 235, 168, 1),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '10 Apr 2025',
        'priority': 'High',
        'description': 'Finalized creative designs for outdoor ads.',
        'attachments': [],
      },
      {
        'title': 'Advertising Outdoors',
        'date': '17 Dec 2022',
        'tasks': '53/70',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '20 Mar 2025',
        'priority': 'Low',
        'description': 'Completed outdoor advertising campaign.',
        'attachments': [],
      },
      {
        'title': 'Create Kanban',
        'date': '17 Nov 2022',
        'tasks': '15/56',
        'assignedBy': 'Amanpreet',
        'assignedTo': 'Shreyas Ladhe',
        'dueDate': '14 - 15 Mar 2025',
        'priority': 'Medium',
        'description': 'Remarkable products campaign completed.',
        'attachments': [],
      },
    ]
  },
};

List<KanbanBoardGroup<KanbanGroup, KanbanGroupItem>> kanbanGroups =
    List.generate(
  _kanbanData.length,
  (index) => KanbanBoardGroup(
    customData: KanbanGroup(
      id: _kanbanData.keys.elementAt(index),
      title: _kanbanData.keys.elementAt(index),
      color: _kanbanData.values.elementAt(index)['color'],
    ),
    id: _kanbanData.keys.elementAt(index),
    name: _kanbanData.keys.elementAt(index),
    items: (_kanbanData.values.elementAt(index)['items'] as List)
        .asMap()
        .entries
        .map<KanbanGroupItem>((entry) {
      final i = entry.key;
      final item = entry.value;
      return KanbanGroupItem(
        itemId: i.toString(),
        title: item['title'],
        date: item['date'],
        completedTasks: int.parse(item['tasks'].toString().split('/').first),
        totalTasks: int.parse(item['tasks'].toString().split('/').last),
        assignedBy: item['assignedBy'] ?? 'Unknown',
        assignedTo: item['assignedTo'] ?? 'Unknown',
        dueDate: item['dueDate'] ?? '',
        priority: item['priority'] ?? 'Low',
        description: item['description'] ?? '',
        attachments: List<String>.from(item['attachments'] ?? []),
      );
    }).toList(),
  ),
);

class KanbanDataManager {
  /// Add a new column if it doesn’t already exist.
  static void addColumn(String columnName, Color color) {
    if (_kanbanData.containsKey(columnName)) return;
    _kanbanData[columnName] = {
      'color': color,
      'items': [],
    };
    _rebuildKanbanGroups();
  }

  /// Add a new task to the specified column.
  /// [taskData] must include keys: title, date, tasks, assignedBy, assignedTo,
  /// dueDate, priority, description, and attachments.
  static void addTask(String columnName, Map<String, dynamic> taskData) {
    if (!_kanbanData.containsKey(columnName)) return;
    (_kanbanData[columnName]['items'] as List).add(taskData);
    _rebuildKanbanGroups();
  }

  /// Modify an existing task in the specified column.
  /// [updatedData] should contain keys to update.
  /// Here, taskId is assumed to be the index (as a string) in the column’s items list.
  static void modifyTask(
      String columnName, String taskId, Map<String, dynamic> updatedData) {
    if (!_kanbanData.containsKey(columnName)) return;
    List items = _kanbanData[columnName]['items'];
    int index = int.tryParse(taskId) ?? -1;
    if (index >= 0 && index < items.length) {
      items[index] = {...items[index], ...updatedData};
      _rebuildKanbanGroups();
    }
  }

  /// Rebuild the global [kanbanGroups] list based on the updated [_kanbanData].
  static void _rebuildKanbanGroups() {
    kanbanGroups = List.generate(
      _kanbanData.length,
      (index) => KanbanBoardGroup(
        customData: KanbanGroup(
          id: _kanbanData.keys.elementAt(index),
          title: _kanbanData.keys.elementAt(index),
          color: _kanbanData.values.elementAt(index)['color'],
        ),
        id: _kanbanData.keys.elementAt(index),
        name: _kanbanData.keys.elementAt(index),
        items: (_kanbanData.values.elementAt(index)['items'] as List)
            .asMap()
            .entries
            .map<KanbanGroupItem>((entry) {
          final i = entry.key;
          final item = entry.value;
          return KanbanGroupItem(
            itemId: i.toString(),
            title: item['title'],
            date: item['date'],
            completedTasks:
                int.parse(item['tasks'].toString().split('/').first),
            totalTasks: int.parse(item['tasks'].toString().split('/').last),
            assignedBy: item['assignedBy'] ?? 'Unknown',
            assignedTo: item['assignedTo'] ?? 'Unknown',
            dueDate: item['dueDate'] ?? '',
            priority: item['priority'] ?? 'Low',
            description: item['description'] ?? '',
            attachments: List<String>.from(item['attachments'] ?? []),
          );
        }).toList(),
      ),
    );
  }
}
