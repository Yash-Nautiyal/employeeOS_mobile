// ignore_for_file: unnecessary_cast

import 'package:employeeos/core/common/actions/file_actions.dart';
import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:sizer/sizer.dart';

class ChatReply extends StatelessWidget {
  final ChatMessage repliedMessage;
  final String currentUserId;
  final bool preview;
  final ThemeData theme;

  const ChatReply({
    super.key,
    required this.repliedMessage,
    required this.currentUserId,
    required this.theme,
    this.preview = false,
  });

  @override
  Widget build(BuildContext context) {
    print(repliedMessage.toJson());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMe = repliedMessage.authorId == currentUserId;
    return Container(
      constraints: BoxConstraints(
        maxWidth: preview == false ? screenWidth * 0.5 : double.infinity,
      ),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppPallete.grey800
            : AppPallete.grey200,
        border: Border(
          left: BorderSide(
            color:
                isMe ? theme.colorScheme.primary : theme.colorScheme.secondary,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: !preview
          ? IntrinsicWidth(
              child: content(theme, repliedMessage, currentUserId, preview))
          : repliedMessage is ImageMessage
              ? IntrinsicWidth(
                  child: content(theme, repliedMessage, currentUserId, preview),
                )
              : content(theme, repliedMessage, currentUserId, preview),
    );
  }
}

Widget content(ThemeData theme, ChatMessage repliedMessage,
    String currentUserId, bool preview) {
  return Row(
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.tertiary,
                fontSize: 15.5.sp,
              ),
            ),
            const SizedBox(height: 5),
            if (repliedMessage is TextMessage)
              Text(
                (repliedMessage).text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.disabledColor,
                  fontSize: 14.sp,
                ),
              )
            else if (repliedMessage is ImageMessage)
              FastCachedImage(
                url: (repliedMessage).url,
                fit: BoxFit.cover,
                width: preview ? 90 : 130,
                height: preview ? 60 : 80,
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
                      width: preview ? 80 : 100,
                      height: preview ? 60 : 80,
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
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                          getFileIcon((repliedMessage as FileMessage).fileType),
                          width: 24,
                          height: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repliedMessage.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontSize: 15.sp),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              formatFileSize(
                                  (repliedMessage as FileMessage).size),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 14.sp,
                              )),
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
  );
}
