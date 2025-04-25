import 'package:employeeos/core/common/actions/file_actions.dart';
import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';

class ChatReply extends StatelessWidget {
  final ChatMessage repliedMessage;
  final String currentUserId;

  const ChatReply({
    super.key,
    required this.repliedMessage,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.5,
      ),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppPallete.grey900,
        border: const Border(
          left: BorderSide(color: AppPallete.primaryLighter),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repliedMessage.authorId == currentUserId
                        ? 'You'
                        : repliedMessage.authorId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (repliedMessage is TextMessage)
                    Text(
                      (repliedMessage as TextMessage).text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (repliedMessage is ImageMessage)
                    FastCachedImage(
                      url: (repliedMessage as ImageMessage).url,
                      fit: BoxFit.cover,
                      width: 130,
                      height: 80,
                      fadeInDuration: const Duration(seconds: 1),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error,
                          color: AppPallete.errorMain,
                          size: 50,
                        );
                      },
                      loadingBuilder: (context, progress) {
                        return Shimmer.fromColors(
                          enabled: true,
                          baseColor: AppPallete.grey400.withOpacity(0.5),
                          highlightColor: AppPallete.grey400.withOpacity(0.2),
                          child: Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppPallete.grey400.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    )
                  else if (repliedMessage is FileMessage)
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppPallete.containerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                                getFileIcon(
                                    (repliedMessage as FileMessage).fileType),
                                width: 24,
                                height: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (repliedMessage as FileMessage).name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    formatFileSize(
                                        (repliedMessage as FileMessage).size),
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Unsupported message type',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
