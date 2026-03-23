import 'dart:ui';

import 'package:employeeos/core/index.dart'
    show CustomExpansionTile, getFileIcon;
import 'package:employeeos/view/kanban/domain/index.dart' show KanbanAttachment;
import 'package:employeeos/view/kanban/presentation/index.dart'
    show ActionButton, AttachmentOwnerAvatar;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanFileAttachmentsTile extends StatelessWidget {
  final ThemeData theme;
  final List<KanbanAttachment> attachments;
  final Future<void> Function(KanbanAttachment attachment)? onDeleteAttachment;
  final bool Function(KanbanAttachment attachment)? canDeleteAttachment;
  final String? Function(KanbanAttachment attachment)? ownerAvatarUrlBuilder;
  final String Function(KanbanAttachment attachment)? ownerInitialsBuilder;
  final Set<String> deletingAttachmentIds;

  const KanbanFileAttachmentsTile({
    super.key,
    required this.theme,
    required this.attachments,
    this.onDeleteAttachment,
    this.canDeleteAttachment,
    this.ownerAvatarUrlBuilder,
    this.ownerInitialsBuilder,
    this.deletingAttachmentIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return CustomExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      collapsedBackgroundColor: theme.colorScheme.surfaceContainerHigh,
      trailing: SvgPicture.asset(
        'assets/icons/arrow/ic-eva_arrow-ios-downward-fill.svg',
        width: 24,
        color: theme.colorScheme.onSurface,
      ),
      title: Text(
        'Files (${attachments.length})',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: attachments.map((attachment) {
            final isDeleting = deletingAttachmentIds.contains(attachment.id);
            final canDelete =
                (canDeleteAttachment?.call(attachment) ?? true) && !isDeleting;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(getFileIcon(attachment.fileType ?? "")),
              title: Text(
                attachment.fileName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: attachment.fileType != null
                  ? Text(
                      attachment.fileType!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: canDelete
                  ? ActionButton(
                      theme: theme,
                      enabled: true,
                      onTap: onDeleteAttachment == null
                          ? null
                          : () => onDeleteAttachment!(attachment),
                    )
                  : AttachmentOwnerAvatar(
                      theme: theme,
                      avatarUrl: ownerAvatarUrlBuilder?.call(attachment),
                      initials: ownerInitialsBuilder?.call(attachment) ?? 'U',
                    ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
