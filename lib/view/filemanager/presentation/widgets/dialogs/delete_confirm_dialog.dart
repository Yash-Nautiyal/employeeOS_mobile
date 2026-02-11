import 'package:employeeos/core/index.dart' show CustomAlertDialog;
import 'package:employeeos/view/filemanager/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteConfirmDialog extends StatefulWidget {
  const DeleteConfirmDialog({
    super.key,
    required this.fileCount,
    required this.folderCount,
    required this.filesInsideFoldersCount,
    required this.fileIds,
    required this.folderIds,
  });

  final int fileCount;
  final int folderCount;
  final int filesInsideFoldersCount;
  final List<String> fileIds;
  final List<String> folderIds;

  @override
  State<DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<DeleteConfirmDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<FilemanagerBloc, FilemanagerState>(
      listenWhen: (previous, current) => current is FilemanagerActionState,
      listener: (context, state) {
        if (context.mounted) Navigator.of(context).pop();
      },
      child: CustomAlertDialog(
        title: 'Delete selected?',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to delete:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.fileCount > 0)
              Text(
                '• ${widget.fileCount} file(s)',
                style: theme.textTheme.bodyMedium,
              ),
            if (widget.folderCount > 0) ...[
              Text(
                '• ${widget.folderCount} folder(s)',
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.filesInsideFoldersCount > 0)
                Text(
                  '  (containing ${widget.filesInsideFoldersCount} file(s))',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        cancelLabel: 'Cancel',
        primaryLabel: 'Delete',
        primaryColor: theme.colorScheme.error,
        loading: _loading,
        onCancel: () {
          if (!_loading) Navigator.of(context).pop();
        },
        primaryOnTap: () {
          setState(() => _loading = true);
          context.read<FilemanagerBloc>().add(
                DeleteSelectedEvent(
                  fileIds: widget.fileIds,
                  folderIds: widget.folderIds,
                ),
              );
        },
      ),
    );
  }
}
