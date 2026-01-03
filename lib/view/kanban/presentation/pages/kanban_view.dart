import 'dart:async';

import 'package:employeeos/core/index.dart' show KanbanDimensions;
import 'package:employeeos/view/kanban/index.dart'
    show
        KanbanColumn,
        KanbanGroupItem,
        KanbanSection,
        kanbanData,
        DragPayload,
        KanbanColumnView;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  static const String _currentUserName = 'Shreyas Ladhe';

  bool _fixedColumns = false;

  late List<KanbanColumn> _columns;

  final GlobalKey _boardKey = GlobalKey();
  final ScrollController _boardScrollController = ScrollController();

  // Hover state for showing ghost preview + section headers on empty sections.
  String? _hoverColumnId;
  KanbanSection? _hoverSection;
  int? _hoverIndex;
  KanbanGroupItem? _hoverTask;

  String? _draggingTaskId;
  Timer? _autoScrollTimer;
  Offset? _lastDragGlobalOffset;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumnsFromSeed();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _boardScrollController.dispose();
    super.dispose();
  }

  List<KanbanColumn> _buildColumnsFromSeed() {
    return kanbanData.entries.map((entry) {
      final title = entry.key;
      final rawItems = (entry.value['items'] as List?) ?? const [];

      final tasks = rawItems.map<KanbanGroupItem>((item) {
        final tasksStr = (item['tasks'] ?? '0/0').toString();
        final parts = tasksStr.split('/');
        final completed = int.tryParse(parts.first.trim()) ?? 0;
        final total =
            int.tryParse(parts.length > 1 ? parts.last.trim() : '0') ?? 0;
        const uuid = Uuid();
        return KanbanGroupItem(
          itemId: uuid.v4().toString(),
          title: (item['title'] ?? '').toString(),
          date: (item['date'] ?? '').toString(),
          completedTasks: completed,
          totalTasks: total,
          assignedBy: (item['assignedBy'] ?? 'Unknown').toString(),
          assignedTo: (item['assignedTo'] ?? 'Unknown').toString(),
          dueDate: (item['dueDate'] ?? '').toString(),
          priority: (item['priority'] ?? 'Low').toString(),
          description: (item['description'] ?? '').toString(),
          attachments: List<String>.from(item['attachments'] ?? const []),
          subtasks: Map<String, bool>.from(item['subtasks'] ?? const {}),
        );
      }).toList();

      final createdByMe = <KanbanGroupItem>[];
      final assignedToMe = <KanbanGroupItem>[];

      for (final t in tasks) {
        if (t.assignedBy == _currentUserName) {
          createdByMe.add(t);
        } else if (t.assignedTo == _currentUserName) {
          assignedToMe.add(t);
        } else {
          // Fallback: keep it in "Assigned to me" so it remains visible.
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

  KanbanColumn _getColumn(String id) => _columns.firstWhere((c) => c.id == id);

  List<KanbanGroupItem> _getSectionList(KanbanColumn col, KanbanSection sec) {
    return sec == KanbanSection.createdByMe
        ? col.createdByMe
        : col.assignedToMe;
  }

  void _clearHoverState() {
    _hoverColumnId = null;
    _hoverSection = null;
    _hoverIndex = null;
    _hoverTask = null;
  }

  void _maybeAutoScroll(Offset globalOffset) {
    // Store last pointer position; actual scrolling is timer-driven so it continues
    // even when the pointer is held still at the edge.
    _lastDragGlobalOffset = globalOffset;

    if (_draggingTaskId == null) return;
    _autoScrollTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _autoScrollTick(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _lastDragGlobalOffset = null;
  }

  void _autoScrollTick() {
    if (_draggingTaskId == null) {
      _stopAutoScroll();
      return;
    }
    final globalOffset = _lastDragGlobalOffset;
    if (globalOffset == null) return;
    if (!_boardScrollController.hasClients) return;

    final ctx = _boardKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;

    final local = box.globalToLocal(globalOffset);
    final width = box.size.width;

    // Wider edge zone + speed ramps up as you get closer to the edge.
    const edge = 140.0;
    const maxStep = 44.0; // px per tick (~2750px/s at 60fps)

    final maxScroll = _boardScrollController.position.maxScrollExtent;
    final cur = _boardScrollController.offset;

    double delta = 0;
    if (local.dx < edge) {
      final t = ((edge - local.dx) / edge).clamp(0.0, 1.0);
      delta = -maxStep * (0.25 + 0.75 * t);
    } else if (local.dx > width - edge) {
      final d = (local.dx - (width - edge)).clamp(0.0, edge);
      final t = (d / edge).clamp(0.0, 1.0);
      delta = maxStep * (0.25 + 0.75 * t);
    } else {
      return;
    }

    final next = (cur + delta).clamp(0.0, maxScroll);
    if (next != cur) {
      // jumpTo is more responsive than animateTo for continuous dragging
      _boardScrollController.jumpTo(next);
    }
  }

  void _moveTask({
    required DragPayload payload,
    required String toColumnId,
    required KanbanSection toSection,
    required int toIndex,
  }) {
    setState(() {
      final fromCol = _getColumn(payload.fromColumn);
      final toCol = _getColumn(toColumnId);

      final fromList = _getSectionList(fromCol, payload.fromSection);
      final toList = _getSectionList(toCol, toSection);

      final fromIndex = fromList.indexWhere((t) => t.id == payload.task.id);
      if (fromIndex == -1) return;

      // Remove from source first.
      final moved = fromList.removeAt(fromIndex);

      // Insert index is based on the rendered list. Adjust when moving inside the same list.
      var insertIndex = toIndex.clamp(0, toList.length);
      if (identical(fromList, toList) && toIndex > fromIndex) {
        insertIndex = (insertIndex - 1).clamp(0, toList.length);
      }

      toList.insert(insertIndex, moved);

      _clearHoverState();
      _draggingTaskId = null;
    });
  }

  void _moveTaskToColumn(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) {
    if (fromColumnId == toColumnId) return;
    setState(() {
      final fromCol = _getColumn(fromColumnId);
      final toCol = _getColumn(toColumnId);

      final fromList = _getSectionList(fromCol, fromSection);
      final toList = _getSectionList(toCol, fromSection);

      final fromIndex = fromList.indexWhere((t) => t.id == task.id);
      if (fromIndex == -1) return;

      final moved = fromList.removeAt(fromIndex);
      toList.add(moved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Kanban", style: theme.textTheme.displaySmall),
              const Spacer(),
              Text("Fixed column", style: theme.textTheme.bodySmall),
              Transform.scale(
                scale: 0.65,
                child: Switch(
                  activeTrackColor: theme.colorScheme.primary,
                  activeColor: Colors.white,
                  value: _fixedColumns,
                  onChanged: (value) => setState(() => _fixedColumns = value),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              key: _boardKey,
              child: Scrollbar(
                controller: _boardScrollController,
                thumbVisibility: false,
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: ListView.separated(
                    controller: _boardScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      right: KanbanDimensions.kColumnGap,
                    ),
                    itemCount: _columns.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: KanbanDimensions.kColumnGap),
                    itemBuilder: (context, index) {
                      final col = _columns[index];
                      return KanbanColumnView(
                        key: ValueKey(col.id),
                        theme: theme,
                        column: col,
                        allColumns: _columns,
                        fixed: _fixedColumns,
                        hoverColumnId: _hoverColumnId,
                        hoverSection: _hoverSection,
                        hoverIndex: _hoverIndex,
                        hoverTask: _hoverTask,
                        draggingTaskId: _draggingTaskId,
                        onDragMove: _maybeAutoScroll,
                        onDragStarted: (taskId) => setState(() {
                          _draggingTaskId = taskId;
                          _lastDragGlobalOffset = null;
                          _autoScrollTimer ??= Timer.periodic(
                            const Duration(milliseconds: 16),
                            (_) => _autoScrollTick(),
                          );
                        }),
                        onDragEnded: () => setState(() {
                          _draggingTaskId = null;
                          _clearHoverState();
                          _stopAutoScroll();
                        }),
                        onHover: (columnId, section, index, task) {
                          setState(() {
                            _hoverColumnId = columnId;
                            _hoverSection = section;
                            _hoverIndex = index;
                            _hoverTask = task;
                          });
                        },
                        onHoverExit: _clearHover,
                        onAccept: (payload, section, index) => _moveTask(
                          payload: payload,
                          toColumnId: col.id,
                          toSection: section,
                          toIndex: index,
                        ),
                        onMoveTaskToColumn: _moveTaskToColumn,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearHover() => setState(_clearHoverState);
}
