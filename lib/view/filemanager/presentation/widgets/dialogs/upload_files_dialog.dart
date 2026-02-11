import 'package:dotted_border/dotted_border.dart';
import 'package:employeeos/core/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../index.dart' show PickedFile;

class UploadFilesDialog extends StatefulWidget {
  final Future<void> Function(List<PickedFile>) onUpload;
  const UploadFilesDialog({super.key, required this.onUpload});

  @override
  State<UploadFilesDialog> createState() => _UploadFilesDialogState();
}

class _UploadFilesDialogState extends State<UploadFilesDialog> {
  final List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;

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

  Future<void> _upload() async {
    if (_selectedFiles.isEmpty || _isUploading) return;
    final picked = _selectedFiles
        .map(
          (f) => PickedFile(
            name: f.name,
            size: f.size,
            fileType: _extension(f.name),
            path: f.path,
          ),
        )
        .toList();
    setState(() => _isUploading = true);
    try {
      await widget.onUpload(picked);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _extension(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0) return '';
    return name.substring(i + 1).toLowerCase();
  }

  Widget _buildDropper(ThemeData theme, bool isLandscape) {
    return GestureDetector(
      onTap: _pickFiles,
      child: DottedBorder(
        radius: const Radius.circular(12),
        padding: EdgeInsets.zero,
        borderType: BorderType.RRect,
        color: theme.dividerColor.withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SvgPicture.asset(
                  'assets/illustrations/container.svg',
                  width: 135,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drop or select file',
                style: isLandscape
                    ? theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w700,
                      )
                    : theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: isLandscape
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                        )
                      : theme.textTheme.bodySmall,
                  children: [
                    const TextSpan(text: 'Drop files here or click to '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: _pickFiles,
                        child: Text(
                          'browse',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: isLandscape ? 10.5 : 12,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildFileList(ThemeData theme, {double? maxHeight}) {
    final useScrollable = maxHeight == double.infinity;
    final list = ListView.separated(
      shrinkWrap: !useScrollable,
      physics: useScrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: _selectedFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final f = _selectedFiles[index];
        return _FileRow(
          name: f.name,
          size: f.size,
          theme: theme,
          fileType: _extension(f.name),
          onRemove: () => _removeFile(index),
        );
      },
    );
    if (useScrollable) return list;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? 180),
      child: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final wideScreen = screenWidth > 440;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final isLandscape = !isPortrait;

    return PopScope(
      canPop: !_isUploading,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
            horizontal: 20, vertical: isWideScreen ? 10 : 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 560,
          ),
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
                if (isLandscape)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildDropper(theme, isLandscape),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: _selectedFiles.isEmpty
                              ? Center(
                                  child: Text(
                                    'Selected files will appear here',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : _buildFileList(theme,
                                  maxHeight: double.infinity),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Flexible(child: _buildDropper(theme, isLandscape)),
                  if (_selectedFiles.isNotEmpty && !wideScreen) ...[
                    const SizedBox(height: 16),
                    _buildFileList(theme),
                  ],
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_selectedFiles.isNotEmpty)
                      CustomTextButton(
                        padding: 0,
                        onClick: _removeAll,
                        child: Text('Remove all',
                            style: theme.textTheme.labelLarge),
                      ),
                    if (_selectedFiles.isNotEmpty) const SizedBox(width: 8),
                    CustomTextButton(
                      backgroundColor: _selectedFiles.isEmpty || _isUploading
                          ? theme.disabledColor.withValues(alpha: 0.3)
                          : theme.colorScheme.tertiary,
                      padding: 0,
                      onClick: () => (_selectedFiles.isEmpty || _isUploading)
                          ? null
                          : _upload(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isUploading)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _selectedFiles.isEmpty
                                    ? theme.dividerColor
                                    : theme.colorScheme.onPrimary,
                              ),
                            )
                          else
                            SvgPicture.asset(
                              'assets/icons/common/solid/ic-eva_cloud-upload-fill.svg',
                              color: _selectedFiles.isEmpty
                                  ? theme.dividerColor
                                  : theme.colorScheme.onPrimary,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            _isUploading ? 'Uploading...' : 'Upload',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _selectedFiles.isEmpty || _isUploading
                                  ? theme.dividerColor
                                  : theme.colorScheme.onPrimary,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  final String fileType;

  const _FileRow({
    required this.name,
    required this.size,
    required this.theme,
    required this.onRemove,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(getFileIcon(fileType), width: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatFileSize(size),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
