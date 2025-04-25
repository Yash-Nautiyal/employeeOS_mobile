import 'dart:io';

import 'package:employeeos/core/common/actions/file_actions.dart'
    show formatFileSize, getFileIcon;
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class ChatMessages extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Color bgColor;
  final List<ImageMessage>?
      batch; // Add this if you want to handle batch messages

  const ChatMessages({
    super.key,
    required this.message,
    required this.isMe,
    required this.bgColor,
    this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (batch != null && batch!.length > 2) {
      // Handle batch images
      final count = batch!.length;
      final maxWidth = isMe
          ? MediaQuery.of(context).size.width * 0.7
          : MediaQuery.of(context).size.width * 0.6;
      // 3-image special layout
      if (count == 3) {
        return Container(
          height: 200,
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: _buildGridImage(batch![0], fillMode: BoxFit.cover)),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: _buildGridImage(batch![1],
                              fillMode: BoxFit.cover)),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SizedBox(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: _buildGridImage(batch![2],
                              fillMode: BoxFit.cover)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      final display = batch!.take(4).toList();
      return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: display.length,
          itemBuilder: (_, idx) {
            final img = display[idx];
            Widget tile = _buildGridImage(img);
            if (idx == 3 && count > 4) {
              // overlay +N
              tile = Stack(
                fit: StackFit.expand,
                children: [
                  tile,
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: Text(
                      '+${count - 3}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              );
            }
            return tile;
          },
        ),
      );
    }

    switch (message.type) {
      case MessageType.text:
        final m = message as TextMessage;
        return ChatBubble(
          clipper: ChatBubbleClipper5(
              type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
          backGroundColor: bgColor,
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMe
                  ? MediaQuery.of(context).size.width * 0.7
                  : MediaQuery.of(context).size.width * 0.6,
            ),
            child: Text(
              m.text,
              style: TextStyle(
                color: isMe ? AppPallete.grey900 : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      case MessageType.image:
        final m = message as ImageMessage;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: m.url.startsWith('http')
                ? FastCachedImage(
                    url: m.url,
                    fit: BoxFit.cover,
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
                : Image.file(File(m.url)),
          ),
        );
      case MessageType.file:
        final m = message as FileMessage;
        final iconPath = getFileIcon(m.fileType);
        final fileSize = formatFileSize(m.size);
        return GestureDetector(
          onTap: () {
            // TODO: implement file open/download
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPallete.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(iconPath, width: 24, height: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(fileSize, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      case MessageType.system:
        final m = message as SystemMessage;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              m.text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        );
      default:
        return ChatBubble(
          clipper: ChatBubbleClipper5(
              type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
          backGroundColor: bgColor,
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          elevation: 0,
          child: Text(
            'Unsupported message',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppPallete.errorMain),
          ),
        );
    }
  }

  Widget _buildGridImage(ImageMessage img, {BoxFit fillMode = BoxFit.cover}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: img.url.startsWith('http')
          ? FastCachedImage(
              url: img.url,
              fit: fillMode,
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
          : Image.file(File(img.url), fit: BoxFit.cover),
    );
  }
}
