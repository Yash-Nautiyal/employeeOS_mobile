import 'package:employeeos/view/kanban/presentation/index.dart' show ActionButton, AttachmentOwnerAvatar;
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:employeeos/core/index.dart'
    show CustomExpansionTile, showCustomImageViewer;
import 'package:employeeos/view/kanban/domain/index.dart' show KanbanAttachment;
import 'package:flutter_svg/svg.dart';

class KanbanImageAttachmentsTile extends StatelessWidget {
  final ThemeData theme;
  final List<KanbanAttachment> attachments;
  final Future<void> Function(KanbanAttachment attachment)? onDeleteAttachment;
  final bool Function(KanbanAttachment attachment)? canDeleteAttachment;
  final String? Function(KanbanAttachment attachment)? ownerAvatarUrlBuilder;
  final String Function(KanbanAttachment attachment)? ownerInitialsBuilder;
  final Set<String> deletingAttachmentIds;

  const KanbanImageAttachmentsTile({
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
    final imageUrls =
        attachments.map((attachment) => attachment.fileUrl).toList();

    return CustomExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      collapsedBackgroundColor: theme.colorScheme.surfaceContainerHigh,
      trailing: SvgPicture.asset(
        'assets/icons/arrow/ic-eva_arrow-ios-downward-fill.svg',
        width: 24,
        color: theme.colorScheme.tertiary,
      ),
      title: Text(
        'Images (${attachments.length})',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              final isDeleting = deletingAttachmentIds.contains(attachment.id);
              final canDelete =
                  (canDeleteAttachment?.call(attachment) ?? true) &&
                      !isDeleting;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => showCustomImageViewer(
                            context,
                            imageUrls: imageUrls,
                            initialIndex: index,
                          ),
                          child: Container(
                            color: theme.colorScheme.surface,
                            child: FastCachedImage(
                              url: attachment.fileUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: canDelete
                            ? ActionButton(
                                theme: theme,
                                enabled: true,
                                onTap: onDeleteAttachment == null
                                    ? null
                                    : () => onDeleteAttachment!(attachment),
                              )
                            : AttachmentOwnerAvatar(
                                theme: theme,
                                avatarUrl:
                                    ownerAvatarUrlBuilder?.call(attachment),
                                initials:
                                    ownerInitialsBuilder?.call(attachment) ??
                                        'U',
                              ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
