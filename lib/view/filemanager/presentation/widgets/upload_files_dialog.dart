import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../index.dart' show FilemanagerBloc, PickedFile, UploadFilesEvent;

/// Displays selected file name and size for list item.
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} Kb';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} Mb';
}

/// Dialog for uploading multiple files. Drop/select area, file list, Upload and Remove all.
class UploadFilesDialog extends StatefulWidget {
  const UploadFilesDialog({super.key});

  @override
  State<UploadFilesDialog> createState() => _UploadFilesDialogState();
}

class _UploadFilesDialogState extends State<UploadFilesDialog> {
  final List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (result == null || !mounted) return;
    setState(() {
      for (final f in result.files) {
        if (f.name.isNotEmpty) _selectedFiles.add(f);
      }
    });
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  void _removeAll() {
    setState(() => _selectedFiles.clear());
  }

  void _upload() {
    if (_selectedFiles.isEmpty) return;
    final picked = _selectedFiles
        .map(
          (f) => PickedFile(
            name: f.name,
            size: f.size,
            fileType: _extension(f.name),
          ),
        )
        .toList();
    context.read<FilemanagerBloc>().add(UploadFilesEvent(picked));
    if (mounted) Navigator.of(context).pop();
  }

  String _extension(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0) return '';
    return name.substring(i + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload files',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              // Drop / select zone
              GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/illustrations/container.svg',
                        width: 135,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drop or select file',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                          children: [
                            const TextSpan(
                                text: 'Drop files here or click to '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: _pickFiles,
                                child: Text(
                                  'browse',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' through your machine.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _selectedFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final f = _selectedFiles[index];
                      return _FileRow(
                        name: f.name,
                        size: f.size,
                        theme: theme,
                        onRemove: () => _removeFile(index),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedFiles.isNotEmpty)
                    TextButton(
                      onPressed: _removeAll,
                      child: Text(
                        'Remove all',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ),
                  if (_selectedFiles.isNotEmpty) const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedFiles.isEmpty ? null : _upload,
                    icon: Icon(
                      Icons.cloud_upload_outlined,
                      size: 18,
                      color: _selectedFiles.isEmpty
                          ? theme.disabledColor
                          : theme.colorScheme.onPrimary,
                    ),
                    label: const Text('Upload'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: theme.scaffoldBackgroundColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final String name;
  final int size;
  final ThemeData theme;
  final VoidCallback onRemove;

  const _FileRow({
    required this.name,
    required this.size,
    required this.theme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.description_outlined,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.tertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                formatFileSize(size),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onRemove,
          style: IconButton.styleFrom(
            minimumSize: const Size(32, 32),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
