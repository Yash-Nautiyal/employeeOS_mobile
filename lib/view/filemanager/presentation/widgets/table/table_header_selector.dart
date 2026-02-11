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
    required this.hasViewerFilesSelected,
    required this.hasAllOwnerFilesSelected,
    required this.onErrorToast,
    this.onShare,
    this.onDelete,
    this.isInsideFolder = false,
    this.onMoveToRoot,
  });

  final int selectedCount;
  final VoidCallback? onClear;
  final VoidCallback? onSelectAll;

  /// When true, the add-to-folder and share buttons are disabled (folders are personal, not shareable).
  final bool hasFolderSelected;

  /// When true, the share buttons is disabled (viewer files are not shareable).
  final bool hasViewerFilesSelected;

  /// When false, user cannot delete files (some files are not owner files).
  final bool hasAllOwnerFilesSelected;

  /// Called when an error occurs.
  final Function({String title, String description}) onErrorToast;

  /// File IDs only (no folder IDs). Used when creating a folder and moving these files into it.
  final List<String> selectedFileIds;

  /// Called when user taps the add-folder icon. Only enabled when no folder is selected and at least one file is selected.
  final VoidCallback? onAddToFolder;

  /// Called when user taps the share icon. Disabled when a folder is selected (folders cannot be shared).
  final VoidCallback? onShare;

  /// Called when user taps the delete (trash) icon. Only enabled when there is selection.
  final VoidCallback? onDelete;

  /// When true, we're viewing files inside a folder; the first action button shows "Move to root" instead of "Add to folder".
  final bool isInsideFolder;

  /// Called when user taps the move-to-root icon. Only relevant when [isInsideFolder] is true and files are selected.
  final VoidCallback? onMoveToRoot;

  bool get _canAddToFolder =>
      !hasFolderSelected &&
      !isInsideFolder &&
      selectedFileIds.isNotEmpty &&
      onAddToFolder != null;

  /// Move to root: enabled when viewing a folder and at least one file is selected.
  bool get _canMoveToRoot =>
      isInsideFolder && selectedFileIds.isNotEmpty && onMoveToRoot != null;

  /// Share is only for files and not viewer files; folders are personal and cannot be shared.
  bool get _canShare =>
      !hasFolderSelected &&
      !hasViewerFilesSelected &&
      selectedFileIds.isNotEmpty &&
      onShare != null;

  /// Delete: only enabled when all files are owner files.
  bool get _canDelete => hasAllOwnerFilesSelected && onDelete != null;

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
            onTap: _canMoveToRoot
                ? onMoveToRoot
                : (_canAddToFolder ? onAddToFolder : null),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                _canMoveToRoot
                    ? 'assets/icons/common/solid/ic-lets-icons-out.svg'
                    : 'assets/icons/common/solid/ic-solar-add-folder-bold.svg',
                color: (_canMoveToRoot || _canAddToFolder)
                    ? theme.primaryColor
                    : theme.primaryColor.withAlpha(50),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (_canShare) {
                onShare?.call();
              } else if (hasFolderSelected) {
                onErrorToast(
                  title: 'Failed to share',
                  description: 'Your selection contains a folder.',
                );
              } else if (hasViewerFilesSelected) {
                onErrorToast(
                  title: 'Failed to share',
                  description: 'Your selection contains viewer files.',
                );
              }
            },
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
            onTap: () {
              if (_canDelete) {
                onDelete?.call();
              } else if (!hasAllOwnerFilesSelected) {
                onErrorToast(
                  title: 'Failed to delete',
                  description: 'Your selection contains shared file(s).',
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                color: _canDelete
                    ? theme.primaryColor
                    : theme.primaryColor.withAlpha(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
