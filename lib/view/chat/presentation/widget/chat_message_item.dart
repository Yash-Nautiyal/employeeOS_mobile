import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_messages.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_reply.dart';
import 'package:flutter/material.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTimestamp;
  final String currentUserId;
  final ChatMessage? repliedMessage;
  final List<ImageMessage>? batch; // Add batch for image messages

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isMe,
    required this.showTimestamp,
    required this.currentUserId,
    this.repliedMessage,
    this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        isMe ? AppPallete.primaryLighter : theme.colorScheme.surfaceContainer;

    return Row(
      mainAxisAlignment: message.type != MessageType.system
          ? isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe && message.type != MessageType.system && showTimestamp)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: CircleAvatar(radius: 14),
          ),
        if (!showTimestamp) const SizedBox(width: 37),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showTimestamp && message.type != MessageType.system)
                Text(
                  '${message.authorId != currentUserId ? '${message.authorId}, ' : ''}${TimeOfDay.fromDateTime(message.createdAt).format(context)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 5),
              if (repliedMessage != null)
                ChatReply(
                  repliedMessage: repliedMessage!,
                  currentUserId: currentUserId,
                ),
              if (batch != null && batch!.isNotEmpty)
                ChatMessages(
                  message: message,
                  isMe: isMe,
                  bgColor: bgColor,
                  batch: batch, // Pass the batch to ChatMessages
                )
              else
                ChatMessages(
                  message: message,
                  isMe: isMe,
                  bgColor: bgColor,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
