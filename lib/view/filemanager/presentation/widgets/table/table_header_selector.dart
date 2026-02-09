import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TableHeaderSelector extends StatelessWidget {
  const TableHeaderSelector({
    super.key,
    required this.selectedCount,
    required this.onClear,
    required this.onSelectAll,
    required this.hasFolderSelected,
    required this.selectedFileIds,
    required this.onAddToFolder,
    this.onShare,
    this.onDelete,
  });

  final int selectedCount;
  final VoidCallback? onClear;
  final VoidCallback? onSelectAll;

  /// When true, the add-to-folder and share buttons are disabled (folders are personal, not shareable).
  final bool hasFolderSelected;

  /// File IDs only (no folder IDs). Used when creating a folder and moving these files into it.
  final List<String> selectedFileIds;

  /// Called when user taps the add-folder icon. Only enabled when no folder is selected and at least one file is selected.
  final VoidCallback? onAddToFolder;

  /// Called when user taps the share icon. Disabled when a folder is selected (folders cannot be shared).
  final VoidCallback? onShare;

  /// Called when user taps the delete (trash) icon. Only enabled when there is selection.
  final VoidCallback? onDelete;

  bool get _canAddToFolder =>
      !hasFolderSelected && selectedFileIds.isNotEmpty && onAddToFolder != null;

  /// Share is only for files; folders are personal and cannot be shared.
  bool get _canShare =>
      !hasFolderSelected && selectedFileIds.isNotEmpty && onShare != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSel = selectedCount > 0;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: hasSel
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Checkbox(
            value: hasSel,
            tristate: true,
            onChanged: (value) {
              if (value == true) {
                onSelectAll?.call();
              } else {
                onClear?.call();
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 10),
          Text(
            hasSel ? '$selectedCount selected' : 'Files',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: _canAddToFolder ? onAddToFolder : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/common/solid/ic-solar-add-folder-bold.svg',
                color: _canAddToFolder
                    ? theme.primaryColor
                    : theme.primaryColor.withAlpha(50),
              ),
            ),
          ),
          InkWell(
            onTap: _canShare ? onShare : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_share-bold.svg',
                color: _canShare
                    ? theme.primaryColor
                    : theme.primaryColor.withAlpha(50),
              ),
            ),
          ),
          InkWell(
            onTap: hasSel && onDelete != null ? onDelete : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                color: hasSel && onDelete != null
                    ? theme.primaryColor
                    : theme.disabledColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
