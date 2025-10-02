import 'package:avatar_stack/animated_avatar_stack.dart';
import 'package:avatar_stack/positions.dart' show RestrictedPositions;
import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show fmtDate, fmtTime;
import 'package:employeeos/core/common/actions/file_actions.dart'
    show formatFileSize, getFileIcon;
import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/table/table_row_shared_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TableDataRow extends StatefulWidget {
  const TableDataRow({
    super.key,
    required this.file,
    required this.selected,
    required this.widthName,
    required this.widthSize,
    required this.widthType,
    required this.widthModified,
    required this.widthShared,
    required this.widthActions,
    required this.onChanged,
    required this.onStar,
    required this.onMenu,
  });

  final FolderFile file;
  final bool selected;
  final double widthName,
      widthSize,
      widthType,
      widthModified,
      widthShared,
      widthActions;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onStar;
  final ValueChanged<String> onMenu;

  @override
  State<TableDataRow> createState() => _TableDataRowState();
}

class _TableDataRowState extends State<TableDataRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        color:
            widget.selected ? theme.colorScheme.primary.withOpacity(.05) : null,
      ),
      child: Row(
        children: [
          // Name cell with checkbox + type badge + file name
          SizedBox(
            width: widget.widthName,
            child: Row(
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: widget.onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  getFileIcon(
                      widget.file.isFolder ? 'folder' : widget.file.fileType!),
                  width: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Size
          SizedBox(
            width: widget.widthSize,
            child: Text(
              formatFileSize(widget.file.size ?? 0),
            ),
          ),

          // Type
          SizedBox(
            width: widget.widthType,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                widget.file.isFolder
                    ? 'Folder'
                    : widget.file.fileType![0].toUpperCase() +
                        widget.file.fileType!.substring(1).toLowerCase(),
              ),
            ),
          ),

          // Modified (date + time stacked)
          SizedBox(
            width: widget.widthModified,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmtDate(widget.file.createdAt)),
                const SizedBox(height: 2),
                Text(
                  fmtTime(widget.file.createdAt),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Shared (star)

          Container(
            alignment: Alignment.centerLeft,
            width: widget.widthShared,
            child: widget.file.sharedWith == null ||
                    widget.file.sharedWith!.isEmpty
                ? const Text('-')
                : SharedUsersTooltip(
                    users:
                        widget.file.sharedWith!, // each: avatarUrl, name, email
                    stackHeight: 40,
                    avatarSize: 20,
                    child: SizedBox(
                      width: double.maxFinite,
                      child: AnimatedAvatarStack(
                        infoWidgetBuilder: (surplus, context) => CircleAvatar(
                          radius: 20,
                          child: Text(
                            '+$surplus',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.black),
                          ),
                        ),
                        key: ValueKey(theme.brightness),
                        borderColor: null,
                        settings: RestrictedPositions(
                          maxCoverage: 0.5,
                        ),
                        avatars: [
                          for (var user in widget.file.sharedWith!)
                            NetworkImage(user.avatarUrl),
                        ],
                      ),
                    ),
                  ),
          ),
          // Actions (kebab)
          SizedBox(
            width: widget.widthActions,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onStar,
                    icon: SvgPicture.asset(
                      widget.file.isFavorite
                          ? 'assets/icons/common/solid/ic-eva_star-fill.svg'
                          : 'assets/icons/common/solid/ic-eva_star-outline.svg',
                      color: widget.file.isFavorite
                          ? Colors.amber
                          : theme.disabledColor,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected: widget.onMenu,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Open', child: Text('Open')),
                      PopupMenuItem(value: 'Rename', child: Text('Rename')),
                      PopupMenuItem(value: 'Move', child: Text('Move')),
                      PopupMenuItem(value: 'Delete', child: Text('Delete')),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
