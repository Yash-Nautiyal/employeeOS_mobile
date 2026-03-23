import 'package:dotted_border/dotted_border.dart';
import 'package:employeeos/core/index.dart'
    show
        AppPallete,
        AppShadows,
        CustomDivider,
        CustomTextButton,
        CustomTextfield;
import 'package:employeeos/view/kanban/domain/index.dart'
    show KanbanAssignee, KanbanAttachment, KanbanGroupItem, KanbanUploadFile;
import 'package:employeeos/view/kanban/presentation/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';

class OverviewSideMenu extends StatelessWidget {
  final KanbanGroupItem task;
  final ThemeData theme;
  final ScrollController sideMenuScrollController;
  final TextEditingController descriptionController;
  final Function(String) onPriorityChange;
  final Function(String) onDescriptionChange;
  final void Function(DateTime? dueStart, DateTime? dueEnd) onDueDateChange;
  final VoidCallback? onSaveDescription;
  final Future<void> Function(List<KanbanUploadFile> files) onAttachmentChange;
  final Future<void> Function(KanbanAttachment attachment) onAttachmentDelete;
  final bool Function(KanbanAttachment attachment) canDeleteAttachment;
  final String? Function(KanbanAttachment attachment)
      attachmentOwnerAvatarUrlBuilder;
  final String Function(KanbanAttachment attachment)
      attachmentOwnerInitialsBuilder;
  final Set<String> deletingAttachmentIds;
  final String currentPriority;
  final DateTime? dueStart;
  final DateTime? dueEnd;
  final List<KanbanAttachment> attachments;
  final bool isAttachmentUploading;
  final List<KanbanAssignee> assignees;
  final VoidCallback onAddAssignees;
  const OverviewSideMenu({
    super.key,
    required this.task,
    required this.theme,
    required this.sideMenuScrollController,
    required this.descriptionController,
    required this.onPriorityChange,
    required this.onDescriptionChange,
    required this.onDueDateChange,
    this.onSaveDescription,
    required this.onAttachmentChange,
    required this.onAttachmentDelete,
    required this.canDeleteAttachment,
    required this.attachmentOwnerAvatarUrlBuilder,
    required this.attachmentOwnerInitialsBuilder,
    required this.deletingAttachmentIds,
    required this.currentPriority,
    required this.dueStart,
    required this.dueEnd,
    required this.attachments,
    required this.isAttachmentUploading,
    required this.assignees,
    required this.onAddAssignees,
  });

  Future<void> _openDueDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialStart = _dateOnly(dueStart ?? dueEnd ?? now);
    final initialEnd = _dateOnly(
      dueEnd != null && !dueEnd!.isBefore(initialStart)
          ? dueEnd!
          : initialStart,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'Select due date range',
      saveText: 'Save',
    );
    if (picked == null) return;
    onDueDateChange(_dateOnly(picked.start), _dateOnly(picked.end));
  }

  Future<List<KanbanUploadFile>> _pickAttachmentFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return const [];
    final picked = <KanbanUploadFile>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      final header = bytes.length > 16 ? bytes.sublist(0, 16) : bytes;
      picked.add(
        KanbanUploadFile(
          fileName: file.name,
          bytes: bytes,
          fileType: lookupMimeType(file.name, headerBytes: header),
          fileSize: file.size,
        ),
      );
    }
    return picked;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dueDateLabel(DateTime? from, DateTime? to) {
    final formatted = KanbanGroupItem.formatDueDateRange(from, to);
    return formatted.isEmpty ? 'Set due range' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final imageAttachments = attachments.where(_isImageAttachment).toList();
    final fileAttachments =
        attachments.where((a) => !_isImageAttachment(a)).toList();

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              // Show assigned details
              Row(
                children: [
                  Text(
                    'Assigned By: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: task.reporter?.avatarUrl != null &&
                            task.reporter!.avatarUrl!.isNotEmpty
                        ? NetworkImage(task.reporter!.avatarUrl!)
                        : null,
                    child: (task.reporter?.avatarUrl == null)
                        ? Text(
                            task.reporter!.initials,
                            style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppPallete.black),
                          )
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    task.reporter?.name ?? 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assigned To: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...assignees.map(
                          (assignee) => Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: assignee.avatarUrl != null &&
                                        assignee.avatarUrl!.isNotEmpty
                                    ? NetworkImage(assignee.avatarUrl!)
                                    : null,
                                child: assignee.avatarUrl == null ||
                                        assignee.avatarUrl!.isEmpty
                                    ? Text(assignee.initials,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppPallete.black))
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                assignee.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceDim,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: AppShadows.card(theme.brightness),
                            ),
                            child: Icon(Icons.add,
                                color: theme.dividerColor, size: 18),
                          ),
                          onPressed: onAddAssignees,
                          tooltip: 'Assign users',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Due Date: ',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openDueDatePicker(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dueDateLabel(dueStart, dueEnd),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Priority selection using chips
              Row(
                children: [
                  Text(
                    'Priority:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: ['Low', 'Medium', 'High'].map((level) {
                        return ChoiceChip(
                          side: BorderSide(
                              color: currentPriority == level
                                  ? theme.colorScheme.onSurface
                                  : theme.dividerColor,
                              width: currentPriority == level ? 2 : 1),
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          showCheckmark: false,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                level == 'Low'
                                    ? 'assets/icons/arrow/ic-solar_double-alt-arrow-down-bold-duotone.svg'
                                    : level == 'Medium'
                                        ? 'assets/icons/arrow/ic-solar_double-alt-arrow-right-bold-duotone.svg'
                                        : 'assets/icons/arrow/ic-solar_double-alt-arrow-up-bold-duotone.svg',
                                color: level == 'Low'
                                    ? AppPallete.infoMain
                                    : level == 'Medium'
                                        ? AppPallete.warningMain
                                        : AppPallete.errorMain,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                level,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                          selected: currentPriority == level,
                          onSelected: (selected) {
                            onPriorityChange(level);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Description TextField
              Text(
                'Description',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                controller: descriptionController,
                theme: theme,
                hintText: 'Add discription here',
                keyboardType: TextInputType.text,
                maxLines: 3,
                onchange: onDescriptionChange,
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: descriptionController,
                builder: (context, value, child) {
                  return value.text != task.description
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: CustomTextButton(
                              backgroundColor: theme.colorScheme.onSurface,
                              padding: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Save',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.scaffoldBackgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                              onClick: () {
                                onDescriptionChange(value.text);
                                onSaveDescription?.call();
                              }),
                        )
                      : const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              // Attachments placeholder

              Text(
                'Attachments',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),

              GestureDetector(
                onTap: isAttachmentUploading
                    ? null
                    : () async {
                        final files = await _pickAttachmentFiles();
                        if (files.isEmpty) return;
                        await onAttachmentChange(files);
                      },
                child: Stack(
                  children: [
                    DottedBorder(
                      radius: const Radius.circular(15),
                      padding: const EdgeInsets.all(3),
                      borderType: BorderType.RRect,
                      color: theme.disabledColor,
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 100,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: theme.colorScheme.surfaceContainer,
                        ),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/common/solid/ic-eva_cloud-upload-fill.svg',
                              height: 45,
                              color: theme.colorScheme.primaryFixed,
                            ),
                            Text(
                              isAttachmentUploading
                                  ? 'Uploading files...'
                                  : 'Drop files here or click to browse',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isAttachmentUploading)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _MovingBorderIndicator(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (imageAttachments.isNotEmpty)
          KanbanImageAttachmentsTile(
            theme: theme,
            attachments: imageAttachments,
            onDeleteAttachment: onAttachmentDelete,
            canDeleteAttachment: canDeleteAttachment,
            ownerAvatarUrlBuilder: attachmentOwnerAvatarUrlBuilder,
            ownerInitialsBuilder: attachmentOwnerInitialsBuilder,
            deletingAttachmentIds: deletingAttachmentIds,
          ),
        if (fileAttachments.isNotEmpty) ...[
          CustomDivider(
            color: theme.dividerColor,
            dashWidth: 2.5,
          ),
          KanbanFileAttachmentsTile(
            theme: theme,
            attachments: fileAttachments,
            onDeleteAttachment: onAttachmentDelete,
            canDeleteAttachment: canDeleteAttachment,
            ownerAvatarUrlBuilder: attachmentOwnerAvatarUrlBuilder,
            ownerInitialsBuilder: attachmentOwnerInitialsBuilder,
            deletingAttachmentIds: deletingAttachmentIds,
          ),
        ],
      ],
    );
  }
}

bool _isImageAttachment(KanbanAttachment attachment) {
  final type = attachment.fileType?.toLowerCase() ?? '';
  if (type.isEmpty) return false;
  return type.startsWith('image/');
}

class _MovingBorderIndicator extends StatefulWidget {
  const _MovingBorderIndicator({required this.color});

  final Color color;

  @override
  State<_MovingBorderIndicator> createState() => _MovingBorderIndicatorState();
}

class _MovingBorderIndicatorState extends State<_MovingBorderIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MovingBorderPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _MovingBorderPainter extends CustomPainter {
  const _MovingBorderPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(1.5),
          const Radius.circular(15),
        ),
      );
    final iterator = path.computeMetrics().iterator;
    if (!iterator.moveNext()) return;
    final metric = iterator.current;
    final segmentLength = metric.length * 0.22;
    final start = metric.length * progress;
    final end = start + segmentLength;
    final segment = Path();
    if (end <= metric.length) {
      segment.addPath(metric.extractPath(start, end), Offset.zero);
    } else {
      segment.addPath(metric.extractPath(start, metric.length), Offset.zero);
      segment.addPath(metric.extractPath(0, end - metric.length), Offset.zero);
    }
    canvas.drawPath(segment, paint);
  }

  @override
  bool shouldRepaint(covariant _MovingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
