import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/domain/entities/participant_model.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_message_reaction_overlay.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_messages.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_reply.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatMessageItem extends StatefulWidget {
  final ChatMessage message;
  final List<ParticipantModel> participants;
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
    required this.participants,
  });

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  final LayerLink _anchor = LayerLink();
  final GlobalKey _bubbleKey = GlobalKey();

  final ValueNotifier<double> _liftT = ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.isMe
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainer.withAlpha(150);

    final reactionPills = () {
      final counts = <String, int>{};
      final userReactions = <String>{};
      for (var entry in widget.message.reactions) {
        counts[entry.emoji] = (counts[entry.emoji] ?? 0) + 1;
        if (entry.userId == widget.currentUserId) {
          userReactions.add(entry.emoji);
        }
      }
      return counts.entries.map((e) {
        final emoji = e.key;
        final cnt = e.value;
        final isUserReaction = userReactions.contains(emoji);
        return Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: theme.scaffoldBackgroundColor,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isUserReaction
                  ? theme.primaryColor
                      .withOpacity(theme.brightness == Brightness.dark ? 1 : .5)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 15)),
                if (cnt > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '×$cnt',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPallete.grey700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList();
    }();
    return Row(
      mainAxisAlignment: widget.message.type != MessageType.system
          ? widget.isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isMe &&
            widget.message.type != MessageType.system &&
            widget.showTimestamp)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(widget.participants
                  .firstWhere((p) => p.id == widget.message.authorId)
                  .avatarUrl),
            ),
          ),
        if (!widget.showTimestamp) const SizedBox(width: 37),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (widget.showTimestamp &&
                      widget.message.type != MessageType.system)
                    Text(
                      '${widget.message.authorId != widget.currentUserId ? '${widget.participants.firstWhere((p) => p.id == widget.message.authorId).name}, ' : ''}${TimeOfDay.fromDateTime(widget.message.createdAt).format(context)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 5),
                  if (widget.repliedMessage != null)
                    ChatReply(
                      repliedMessage: widget.repliedMessage!,
                      currentUserId: widget.currentUserId,
                      theme: theme,
                    ),
                  if (widget.batch != null && widget.batch!.isNotEmpty)
                    ChatMessages(
                      message: widget.message,
                      isMe: widget.isMe,
                      bgColor: bgColor,
                      batch: widget.batch,
                      imageUrlsandFileName: widget.imageUrlsandFileName,
                    )
                  else
                    SwipeTo(
                      onRightSwipe: !widget.isMe
                          ? (details) {
                              // Pass the swiped message to the parent widget
                              widget.onSwipeMessage(widget.message);
                            }
                          : null,
                      onLeftSwipe: widget.isMe
                          ? (details) {
                              // Pass the swiped message to the parent widget
                              widget.onSwipeMessage(widget.message);
                            }
                          : null,
                      iconColor: AppPallete.grey600,
                      swipeSensitivity: 5,
                      offsetDx: .15,
                      iconSize: 24,
                      child: GestureDetector(
                        onLongPress: () {
                          // measure current bubble width for edge-aligned reaction bar
                          final box = _bubbleKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box == null) return;
                          final bubbleWidth = box.size.width;

                          final overlay =
                              Overlay.of(context, rootOverlay: true);
                          final route = ModalRoute.of(context);

                          OverlayEntry? entry;
                          LocalHistoryEntry? backEntry;
                          bool isClosed = false;

                          void requestClose() {
                            if (isClosed) return;
                            isClosed = true;
                            // fade the in-list bubble back
                            _liftT.value = 0.0;

                            if (backEntry != null && route != null) {
                              backEntry!
                                  .remove(); // onRemove will remove the entry exactly once
                              return;
                            }
                            if (entry?.mounted ?? false) entry!.remove();
                            entry = null;
                            backEntry = null;
                          }

                          entry = OverlayEntry(
                            builder: (_) => ChatMessageReactionsOverlay(
                              anchor: _anchor,
                              bubbleWidth: bubbleWidth,
                              isMe: widget.isMe,
                              bubble: ChatMessages(
                                message: widget.message,
                                isMe: widget.isMe,
                                bgColor: bgColor,
                                imageUrlsandFileName:
                                    widget.imageUrlsandFileName,
                              ),
                              onPick: (emoji) => widget.handleReaction(
                                  emoji, widget.message.id),
                              onProgress: (v) =>
                                  _liftT.value = v, // << sync ghosting progress
                              onRequestClose: requestClose,
                            ),
                          );

                          if (route != null) {
                            backEntry = LocalHistoryEntry(onRemove: () {
                              if (entry?.mounted ?? false) entry!.remove();
                              entry = null;
                              backEntry = null;
                            });
                            route.addLocalHistoryEntry(backEntry!);
                          }

                          overlay.insert(entry!);
                        },
                        child: CompositedTransformTarget(
                          link: _anchor,
                          child: KeyedSubtree(
                            key: _bubbleKey,
                            child: ValueListenableBuilder<double>(
                              valueListenable: _liftT,
                              builder: (context, t, child) {
                                // ghost the original bubble while lifted:
                                // opacity: 1 -> 0.35, scale: 1 -> 0.96
                                final opacity = 1.0 - 0.65 * t;
                                final scale = 1.0 - 0.04 * t;
                                return Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: widget.isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: child,
                                  ),
                                );
                              },
                              child: ChatMessages(
                                message: widget.message,
                                isMe: widget.isMe,
                                bgColor: bgColor,
                                imageUrlsandFileName:
                                    widget.imageUrlsandFileName,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (reactionPills.isNotEmpty)
                Positioned(
                  bottom: -23.5,
                  left: widget.isMe ? null : 10,
                  right: widget.isMe ? 10 : null,
                  child: Wrap(
                    alignment:
                        widget.isMe ? WrapAlignment.end : WrapAlignment.start,
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
