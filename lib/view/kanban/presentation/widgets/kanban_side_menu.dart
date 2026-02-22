import 'package:employeeos/core/index.dart'
    show
        CustomAlertDialog,
        CustomAlertDialogStyle,
        CustomDropdown,
        CustomToggleButton,
        showCustomToast;
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/overview_side_menu.dart';
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/subtasks_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class KanbanSideMenu extends StatefulWidget {
  final KanbanGroupItem task;
  final KanbanColumn group;
  final List<KanbanColumn> allColumns;
  final void Function(String toColumnId) onMoveColumn;
  final void Function(String priority) onPriorityChanged;
  final void Function(DateTime? dueStart, DateTime? dueEnd, String columnId,
      KanbanSection section, String taskId) onDueDateChanged;
  final Future<List<KanbanAttachment>> Function(
      String taskId, List<KanbanUploadFile> files) onAttachmentUpload;
  final Future<void> Function(String taskId, String attachmentId)
      onAttachmentDelete;
  final Future<void> Function(
    String columnId,
    KanbanSection section,
    String taskId,
  ) onDeleteTask;
  final void Function(List<KanbanAssignee> assignees) onAssigneesChanged;
  final void Function(String name) onSubtaskAdded;
  final void Function(String subtaskId, bool completed) onSubtaskToggled;
  final void Function(String subtaskId, String name) onSubtaskRenamed;
  final void Function(String subtaskId) onSubtaskDeleted;

  /// Called when user saves description. Parent dispatches to bloc.
  final void Function(String description, String columnId,
      KanbanSection section, String taskId) onSaveDescription;

  /// Called when user taps Add assignees. Parent shows dialog (and loads users via bloc).
  final void Function(
    BuildContext context,
    List<KanbanAssignee> currentAssignees,
    void Function(List<KanbanAssignee>) onDone,
  ) onOpenAssigneePicker;

  const KanbanSideMenu({
    super.key,
    required this.task,
    required this.group,
    required this.allColumns,
    required this.onMoveColumn,
    required this.onPriorityChanged,
    required this.onDueDateChanged,
    required this.onAttachmentUpload,
    required this.onAttachmentDelete,
    required this.onDeleteTask,
    required this.onAssigneesChanged,
    required this.onSubtaskAdded,
    required this.onSubtaskToggled,
    required this.onSubtaskRenamed,
    required this.onSubtaskDeleted,
    required this.onSaveDescription,
    required this.onOpenAssigneePicker,
  });

  @override
  State<KanbanSideMenu> createState() => _KanbanSideMenuState();
}

class _KanbanSideMenuState extends State<KanbanSideMenu> {
  late String _priority;
  late String _group;
  late TextEditingController _descriptionController;
  late List<String> _columnIds;
  late Map<String, String> _columnLabels;
  late List<KanbanSubtask> _subtasks;
  late List<KanbanAssignee> _assignees;
  late List<KanbanAttachment> _attachments;
  late DateTime? _dueStart;
  late DateTime? _dueEnd;
  late ScrollController _sideMenuScrollController;
  bool showOverView = true;
  bool _isUploadingAttachments = false;
  final Set<String> _deletingAttachmentIds = {};

  @override
  void initState() {
    super.initState();
    _syncFromTask();
    _sideMenuScrollController = ScrollController();
  }

  void _syncFromTask() {
    _group = widget.group.id;
    _priority = _capitalizePriority(widget.task.priority);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _columnIds = widget.allColumns.map((c) => c.id).toList();
    _columnLabels = {
      for (final c in widget.allColumns) c.id: c.title,
    };
    _subtasks = List<KanbanSubtask>.from(widget.task.subtasks);
    _assignees = widget.task.assignees.map((a) => a.copyWith()).toList();
    _attachments = widget.task.attachments.map((a) => a.copyWith()).toList();
    _dueStart = widget.task.dueStart;
    _dueEnd = widget.task.dueEnd;
  }

  static String _capitalizePriority(String p) {
    final lower = p.toLowerCase();
    if (lower == 'low') return 'Low';
    if (lower == 'medium') return 'Medium';
    if (lower == 'high') return 'High';
    return p;
  }

  KanbanAssignee? _resolveAttachmentOwner(KanbanAttachment attachment) {
    final ownerId = attachment.uploadedBy;
    if (ownerId == null || ownerId.isEmpty) return null;
    final reporter = widget.task.reporter;
    if (reporter != null && reporter.userId == ownerId) return reporter;
    for (final assignee in _assignees) {
      if (assignee.userId == ownerId) return assignee;
    }
    return null;
  }

  String? _attachmentOwnerAvatarUrl(KanbanAttachment attachment) =>
      _resolveAttachmentOwner(attachment)?.avatarUrl;

  String _attachmentOwnerInitials(KanbanAttachment attachment) {
    final owner = _resolveAttachmentOwner(attachment);
    if (owner != null) return owner.initials;
    final rawId = attachment.uploadedBy ?? '';
    if (rawId.length >= 2) {
      return rawId.substring(0, 2).toUpperCase();
    }
    if (rawId.isNotEmpty) {
      return rawId.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  bool _isTaskCreatedByCurrentUser() {
    return widget.group.createdByMe.any((t) => t.id == widget.task.id);
  }

  Future<void> _confirmDeleteTask() async {
    final isCreatedByMe = _isTaskCreatedByCurrentUser();
    if (!isCreatedByMe) {
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Only task creator can delete this task',
      );
      return;
    }
    final section =
        isCreatedByMe ? KanbanSection.createdByMe : KanbanSection.assignedToMe;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        style: CustomAlertDialogStyle.danger,
        title: 'Delete task?',
        content: Text(
          'This will permanently delete "${widget.task.title}" and its details.',
        ),
        cancelLabel: 'Cancel',
        primaryLabel: 'Delete',
        onCancel: () => Navigator.of(ctx).pop(false),
        primaryOnTap: () => Navigator.of(ctx).pop(true),
      ),
    );
    if (confirm != true) return;
    await widget.onDeleteTask(
      widget.task.columnId,
      section,
      widget.task.id,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void didUpdateWidget(covariant KanbanSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id ||
        oldWidget.task.description != widget.task.description ||
        oldWidget.task.priority != widget.task.priority ||
        oldWidget.task.dueStart != widget.task.dueStart ||
        oldWidget.task.dueEnd != widget.task.dueEnd ||
        oldWidget.task.attachments.length != widget.task.attachments.length ||
        oldWidget.task.subtasks.length != widget.task.subtasks.length ||
        oldWidget.task.assignees.length != widget.task.assignees.length) {
      _syncFromTask();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final canDeleteTask = _isTaskCreatedByCurrentUser();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0)
                .copyWith(top: MediaQuery.of(context).padding.top + 10),
            child: Row(
              children: [
                IntrinsicWidth(
                  child: CustomDropdown(
                    theme: theme,
                    onChange: (value) {
                      if (value == null || value == _group) return;
                      setState(() => _group = value!);
                      widget.onMoveColumn(value);
                    },
                    label: '',
                    value: _group,
                    items: _columnIds.map((id) {
                      return DropdownMenuItem(
                        value: id,
                        child: Text(
                          _columnLabels[id] ?? id,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _confirmDeleteTask,
                  icon: SvgPicture.asset(
                    'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                    colorFilter: ColorFilter.mode(
                      canDeleteTask
                          ? theme.colorScheme.error
                          : theme.disabledColor,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  tooltip: canDeleteTask
                      ? 'Delete task'
                      : 'Only task creator can delete',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          CustomToggleButton(
            values: const ["Overview", "Subtasks"],
            theme: theme,
            initialIndex: showOverView ? 0 : 1,
            onToggle: (value) {
              setState(() => showOverView = value == 0);
            },
          ),
          const SizedBox(height: 15),
          showOverView
              ? OverviewSideMenu(
                  task: widget.task,
                  sideMenuScrollController: _sideMenuScrollController,
                  theme: theme,
                  descriptionController: _descriptionController,
                  onPriorityChange: (value) {
                    setState(() => _priority = value);
                    widget.onPriorityChanged(value);
                  },
                  onDescriptionChange: (value) {
                    setState(() => _descriptionController.text = value);
                  },
                  dueStart: _dueStart,
                  dueEnd: _dueEnd,
                  onDueDateChange: (start, end) {
                    setState(() {
                      _dueStart = start;
                      _dueEnd = end;
                    });
                    final section = widget.group.createdByMe
                            .any((t) => t.id == widget.task.id)
                        ? KanbanSection.createdByMe
                        : KanbanSection.assignedToMe;
                    widget.onDueDateChanged(
                      start,
                      end,
                      widget.task.columnId,
                      section,
                      widget.task.id,
                    );
                  },
                  onSaveDescription: () {
                    final section = widget.group.createdByMe
                            .any((t) => t.id == widget.task.id)
                        ? KanbanSection.createdByMe
                        : KanbanSection.assignedToMe;
                    widget.onSaveDescription(
                      _descriptionController.text,
                      widget.task.columnId,
                      section,
                      widget.task.id,
                    );
                  },
                  attachments: _attachments,
                  isAttachmentUploading: _isUploadingAttachments,
                  onAttachmentChange: (pickedFiles) async {
                    if (pickedFiles.isEmpty || _isUploadingAttachments) return;
                    setState(() => _isUploadingAttachments = true);
                    try {
                      final uploaded = await widget.onAttachmentUpload(
                        widget.task.id,
                        pickedFiles,
                      );
                      if (!mounted) return;
                      setState(() {
                        _attachments = [..._attachments, ...uploaded];
                        _isUploadingAttachments = false;
                      });
                      showCustomToast(
                        context: context,
                        type: ToastificationType.success,
                        title:
                            '${uploaded.length} file${uploaded.length == 1 ? '' : 's'} uploaded successfully',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isUploadingAttachments = false);
                      final message = e.toString();
                      showCustomToast(
                        context: context,
                        type: ToastificationType.error,
                        title: message.startsWith('Exception:')
                            ? message.substring('Exception:'.length).trim()
                            : message,
                      );
                    }
                  },
                  onAttachmentDelete: (attachment) async {
                    if (_deletingAttachmentIds.contains(attachment.id)) return;
                    if (currentUserId == null ||
                        attachment.uploadedBy != currentUserId) {
                      showCustomToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Only uploader can delete this attachment',
                      );
                      return;
                    }
                    setState(() => _deletingAttachmentIds.add(attachment.id));
                    try {
                      await widget.onAttachmentDelete(
                        widget.task.id,
                        attachment.id,
                      );
                      if (!mounted) return;
                      setState(() {
                        _attachments = _attachments
                            .where((a) => a.id != attachment.id)
                            .toList();
                        _deletingAttachmentIds.remove(attachment.id);
                      });
                      showCustomToast(
                        context: context,
                        type: ToastificationType.success,
                        title: 'Attachment deleted',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(
                          () => _deletingAttachmentIds.remove(attachment.id));
                      final message = e.toString();
                      showCustomToast(
                        context: context,
                        type: ToastificationType.error,
                        title: message.startsWith('Exception:')
                            ? message.substring('Exception:'.length).trim()
                            : message,
                      );
                    }
                  },
                  canDeleteAttachment: (attachment) =>
                      currentUserId != null &&
                      attachment.uploadedBy == currentUserId,
                  attachmentOwnerAvatarUrlBuilder: _attachmentOwnerAvatarUrl,
                  attachmentOwnerInitialsBuilder: _attachmentOwnerInitials,
                  deletingAttachmentIds: _deletingAttachmentIds,
                  currentPriority: _priority,
                  assignees: _assignees,
                  onAddAssignees: () => widget.onOpenAssigneePicker(
                    context,
                    _assignees,
                    (chosen) {
                      setState(() => _assignees = chosen);
                      widget.onAssigneesChanged(chosen);
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0)
                      .copyWith(bottom: 10),
                  child: SubtasksSideMenu(
                    taskId: widget.task.id,
                    initialSubtasks: _subtasks,
                    onSubtaskAdded: (name) {
                      setState(() {});
                      widget.onSubtaskAdded(name);
                    },
                    onSubtaskToggled: (subtaskId, completed) {
                      setState(() {
                        final i =
                            _subtasks.indexWhere((s) => s.id == subtaskId);
                        if (i != -1) {
                          _subtasks = List.from(_subtasks)
                            ..[i] = _subtasks[i].copyWith(completed: completed);
                        }
                      });
                      widget.onSubtaskToggled(subtaskId, completed);
                    },
                    onSubtaskRenamed: (subtaskId, name) {
                      setState(() {
                        final i =
                            _subtasks.indexWhere((s) => s.id == subtaskId);
                        if (i != -1) {
                          _subtasks = List.from(_subtasks)
                            ..[i] = _subtasks[i].copyWith(name: name);
                        }
                      });
                      widget.onSubtaskRenamed(subtaskId, name);
                    },
                    onSubtaskDeleted: (subtaskId) {
                      setState(() {
                        _subtasks =
                            _subtasks.where((s) => s.id != subtaskId).toList();
                      });
                      widget.onSubtaskDeleted(subtaskId);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
