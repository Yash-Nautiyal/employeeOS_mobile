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

  KanbanGroupItem({
    required this.itemId,
    required this.title,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
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
        'tasks': '30/48'
      },
      {'title': 'Create Remarkable', 'date': '17 Nov 2022', 'tasks': '15/56'},
      {
        'title': 'Advertisers Embrace Rich Media',
        'date': '22 Oct 2022',
        'tasks': '18/67'
      },
      {
        'title': 'Meet the People Who Train',
        'date': '15 Dec 2022',
        'tasks': '24/46'
      }
    ]
  },
  'In progress': {
    'color': const Color.fromRGBO(255, 230, 168, 1),
    'items': [
      {
        'title': 'Advertising Outdoors',
        'date': '17 Dec 2022',
        'tasks': '53/70',
      },
      {
        'title': 'Digital Marketing Campaign',
        'date': '21 Dec 2022',
        'tasks': '34/60',
      },
      {
        'title': 'Social Media Strategy',
        'date': '15 Dec 2022',
        'tasks': '28/45',
      },
      {
        'title': 'Content Creation Plan',
        'date': '19 Dec 2022',
        'tasks': '41/65',
      },
      {
        'title': 'Email Newsletter Design',
        'date': '22 Dec 2022',
        'tasks': '37/50',
      },
      {
        'title': 'Brand Identity Update',
        'date': '18 Dec 2022',
        'tasks': '45/75',
      },
    ]
  },
  'Testing': {
    'color': const Color.fromARGB(255, 235, 235, 148),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
      },
      {
        'title': 'Promotional Advertising Speciality',
        'date': '17 Nov 2022',
        'tasks': '15/15'
      },
      {
        'title': 'Search Engine OPtimization',
        'date': '22 Oct 2022',
        'tasks': '67/67'
      },
    ]
  },
  'Done': {
    'color': const Color.fromRGBO(148, 235, 168, 1),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
      },
      {
        'title': 'Promotional Advertising Speciality',
        'date': '17 Nov 2022',
        'tasks': '15/15'
      },
      {
        'title': 'Search Engine OPtimization',
        'date': '22 Oct 2022',
        'tasks': '67/67'
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
        .indexed
        .map<KanbanGroupItem>((item) {
      return KanbanGroupItem(
        itemId: item.$1.toString(),
        title: item.$2['title'],
        date: item.$2['date'],
        // avatar: avatars[item.$1 % 4],
        completedTasks: int.parse(item.$2['tasks'].toString().split('/').first),
        totalTasks: int.parse(item.$2['tasks'].toString().split('/').last),
      );
    }).toList(),
  ),
);
