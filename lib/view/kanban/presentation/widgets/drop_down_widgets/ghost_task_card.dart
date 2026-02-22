import 'package:employeeos/view/kanban/domain/index.dart' show KanbanGroupItem;
import 'package:flutter/material.dart';
import 'package:employeeos/view/kanban/presentation/index.dart' show KanbanTaskCard;

class GhostTaskCard extends StatelessWidget {
  const GhostTaskCard({super.key, required this.theme, required this.task});

  final ThemeData theme;
  final KanbanGroupItem task;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: KanbanTaskCard(theme: theme, task: task),
    );
  }
}
