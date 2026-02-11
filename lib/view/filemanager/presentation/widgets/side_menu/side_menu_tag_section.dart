import 'package:employeeos/core/index.dart' show CustomTextfield;
import 'package:employeeos/view/filemanager/index.dart' show FileRole, FileTag;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                  .copyWith(right: canRemove ? 5 : 10),
              decoration: BoxDecoration(
                color: isPersonal
                    ? widget.theme.colorScheme.primary.withValues(alpha: 0.15)
                    : widget.theme.disabledColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPersonal
                      ? widget.theme.colorScheme.primary.withValues(alpha: 0.2)
                      : widget.theme.disabledColor.withValues(alpha: 0.2),
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
                    InkWell(
                      onTap: () =>
                          widget.onRemoveTag(tag.tagName, tag.isPersonal),
                      child: SvgPicture.asset(
                          'assets/icons/common/solid/ic-solar_close-circle-bold.svg',
                          width: 20,
                          height: 20,
                          color: isPersonal
                              ? widget.theme.colorScheme.primary
                              : widget.theme.disabledColor
                                  .withValues(alpha: 0.4)),
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
              child: CustomTextfield(
                controller: _addController,
                keyboardType: TextInputType.text,
                theme: widget.theme,
                onchange: (value) {},
                hintText: '#Add a tag',
                onSubmitted: (value) => _submitTag(value),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _submitTag(_addController.text),
              child: SvgPicture.asset(
                  width: 28,
                  'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
                  color: widget.theme.colorScheme.primary),
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
