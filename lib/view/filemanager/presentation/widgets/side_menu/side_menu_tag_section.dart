import 'package:employeeos/view/filemanager/index.dart' show FileRole, FileTag;
import 'package:flutter/material.dart';

class SideMenuTagSection extends StatefulWidget {
  const SideMenuTagSection({
    super.key,
    required this.theme,
    required this.fileId,
    required this.tags,
    required this.role,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  final ThemeData theme;
  final String fileId;
  final List<FileTag> tags;
  final FileRole? role;
  final void Function(String tagName, bool isPersonal) onAddTag;
  final void Function(String tagName, bool isPersonal) onRemoveTag;

  @override
  State<SideMenuTagSection> createState() => _SideMenuTagSectionState();
}

class _SideMenuTagSectionState extends State<SideMenuTagSection> {
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  bool _canRemoveTag(FileTag tag) {
    if (widget.role == FileRole.viewer) return tag.isPersonal;
    return true;
  }

  // bool get _canAddTag => widget.role != null;

  bool get _addAsPersonal => widget.role == FileRole.viewer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.tags.map((tag) {
            final canRemove = _canRemoveTag(tag);
            final isPersonal = tag.isPersonal;
            print('tag: $tag' 'isPersonal: $isPersonal');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                  .copyWith(right: 5),
              decoration: BoxDecoration(
                color: isPersonal
                    ? widget.theme.colorScheme.primary.withValues(alpha: 0.15)
                    : null,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPersonal
                      ? widget.theme.colorScheme.primary
                      : widget.theme.disabledColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag.tagName,
                    style: widget.theme.textTheme.labelLarge?.copyWith(
                      color: isPersonal
                          ? widget.theme.colorScheme.primary
                          : widget.theme.disabledColor,
                    ),
                  ),
                  if (canRemove) ...[
                    const SizedBox(width: 5),
                    IconButton(
                      onPressed: () =>
                          widget.onRemoveTag(tag.tagName, tag.isPersonal),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ]
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addController,
                decoration: InputDecoration(
                  hintText: '#Add a tag',
                  hintStyle: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.disabledColor,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) => _submitTag(value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _submitTag(_addController.text),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _submitTag(String value) {
    final tagName = value.trim();
    if (tagName.isEmpty) return;
    widget.onAddTag(tagName, _addAsPersonal);
    _addController.clear();
  }
}
