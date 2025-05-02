import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_messages.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_reply.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTimestamp;
  final String currentUserId;
  final ChatMessage? repliedMessage;
  final Function(ChatMessage message) onSwipeMessage;
  final Map<String, String> imageUrlsandFileName;
  final Function(String reaction, String messageId) handleReaction;
  final List<ImageMessage>? batch; // Add batch for image messages

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isMe,
    required this.showTimestamp,
    required this.currentUserId,
    required this.onSwipeMessage,
    required this.handleReaction,
    this.imageUrlsandFileName = const {},
    this.repliedMessage,
    this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        isMe ? AppPallete.primaryLighter : theme.colorScheme.surfaceContainer;

    void showEmojiBottomSheet({
      required ChatMessage message,
    }) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 310,
            child: EmojiPicker(
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                  emojiSizeMax: 28 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.20
                          : 1.0),
                ),
                viewOrderConfig: const ViewOrderConfig(
                  top: EmojiPickerItem.searchBar,
                  middle: EmojiPickerItem.emojiView,
                  bottom: EmojiPickerItem.categoryBar,
                ),
                skinToneConfig: const SkinToneConfig(
                  
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  iconColorSelected: AppPallete.primaryMain,
                  indicatorColor: AppPallete.primaryMain,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: theme.colorScheme.surfaceDim,
                  buttonColor: Colors.transparent,
                ),
                searchViewConfig: const SearchViewConfig(
                  
                ),
              ),
              onEmojiSelected: ((category, emoji) {
                // pop the bottom sheet
                Navigator.pop(context);
                handleReaction(emoji.emoji, message.id);
              }),
            ),
          );
        },
      );
    }

    final reactionPills = () {
      final counts = <String, int>{};
      final userReactions = <String>{};
      for (var entry in message.reactions.entries) {
        counts[entry.value] = (counts[entry.value] ?? 0) + 1;
        if (entry.key == currentUserId) {
          userReactions.add(entry.value);
        }
      }
      return counts.entries.map((e) {
        final emoji = e.key;
        final cnt = e.value;
        final isUserReaction = userReactions.contains(emoji);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isUserReaction
                ? AppPallete.primaryLight
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              if (cnt > 1) ...[
                const SizedBox(width: 2),
                Text(
                  '×$cnt',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPallete.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList();
    }();
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
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
                      batch: batch,
                      imageUrlsandFileName: imageUrlsandFileName,
                    )
                  else
                    SwipeTo(
                      onRightSwipe: !isMe
                          ? (details) {
                              // Pass the swiped message to the parent widget
                              onSwipeMessage(message);
                            }
                          : null,
                      onLeftSwipe: isMe
                          ? (details) {
                              // Pass the swiped message to the parent widget
                              onSwipeMessage(message);
                            }
                          : null,
                      iconColor: AppPallete.grey600,
                      swipeSensitivity: 10,
                      offsetDx: .2,
                      iconSize: 24,
                      child: GestureDetector(
                        onLongPress: () {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (context) {
                                return ReactionsDialogWidget(
                                  id: message.id,
                                  messageWidget: ChatMessages(
                                      message: message,
                                      isMe: isMe,
                                      bgColor: bgColor),
                                  onReactionTap: (reaction) {
                                    if (reaction == '➕') {
                                      showEmojiBottomSheet(message: message);
                                    } else {
                                      handleReaction(reaction, message.id);
                                    }
                                  },
                                  onContextMenuTap: (menuItem) {},
                                );
                              },
                            ),
                          );
                        },
                        child: Hero(
                          tag: message.id,
                          child: Column(
                            children: [
                              ChatMessages(
                                message: message,
                                isMe: isMe,
                                bgColor: bgColor,
                                imageUrlsandFileName: imageUrlsandFileName,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (reactionPills.isNotEmpty)
                Positioned(
                  bottom: -20, // overlap by 10px
                  left: isMe ? null : 10, // left-aligned on incoming
                  right: isMe ? 10 : null, // right-aligned on outgoing
                  child: Wrap(
                    spacing: 4,
                    children: reactionPills,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
