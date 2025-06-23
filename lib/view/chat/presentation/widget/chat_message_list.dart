import 'dart:async';
import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show formatDate, isSameDay, isSameMinute;
import 'package:flutter/material.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_message_item.dart';

/// A widget that displays a scrollable list of chat messages with a sticky date header.
class ChatMessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final ThemeData theme;
  final Function(ChatMessage message) onSwipeMessage;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.theme,
    required this.currentUserId,
    required this.onSwipeMessage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatMessageListState createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _controller = ScrollController();
  final Map<String, String> _imagesUrlsandFileName = {};
  String? _stickyDate;
  bool _showSticky = false;
  Timer? _fadeTimer;

  void _getallurls() {
    for (var message in widget.messages) {
      if (message is ImageMessage) {
        _imagesUrlsandFileName[message.url] = message.name;
      }
    }
  }

  void addReaction({
    required String messageId,
    required String reaction,
  }) {
    setState(() {
      final message = widget.messages.firstWhere((msg) => msg.id == messageId);
      if (message.reactions[widget.currentUserId] == reaction) {
        // If the same reaction is sent by the same user, clear the reaction
        message.reactions.remove(widget.currentUserId);
      } else {
        // Otherwise, add or update the reaction
        message.reactions[widget.currentUserId] = reaction;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getallurls();
    if (widget.messages.isNotEmpty) {
      _stickyDate = formatDate(widget.messages.first.createdAt);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification ||
                notification is UserScrollNotification) {
              _updateSticky(notification.metrics);
            }
            return false;
          },
          child: ListView(
            controller: _controller,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
            children: [
              for (int i = 0; i < widget.messages.length; i++) ...[
                () {
                  final msg = widget.messages[i];
                  final isMe = msg.authorId == widget.currentUserId;

                  // 1. compute exactly as you do for normal items:
                  final bool showDateDivider =
                      i == widget.messages.length - 1 ||
                          !isSameDay(
                            widget.messages[i].createdAt,
                            widget.messages[i + 1].createdAt,
                          );
                  final bool showTimestamp = i == widget.messages.length - 1 ||
                      !isSameMinute(
                        widget.messages[i].createdAt,
                        widget.messages[i + 1].createdAt,
                      );
                  final repliedMessage = msg.replyTo != null
                      ? widget.messages.firstWhere((m) => m.id == msg.replyTo)
                      : null;

                  // 2. Batch logic
                  if (msg is ImageMessage &&
                      i + 1 < widget.messages.length &&
                      widget.messages[i + 1] is ImageMessage &&
                      widget.messages[i + 1].authorId == msg.authorId &&
                      isSameMinute(
                        msg.createdAt,
                        widget.messages[i + 1].createdAt,
                      )) {
                    // collect batch
                    final batch = <ImageMessage>[msg];
                    int j = i + 1;
                    while (j < widget.messages.length &&
                        widget.messages[j] is ImageMessage &&
                        (widget.messages[j] as ImageMessage).authorId ==
                            msg.authorId &&
                        isSameMinute(
                          msg.createdAt,
                          widget.messages[j].createdAt,
                        )) {
                      batch.add(widget.messages[j] as ImageMessage);
                      j++;
                    }
                    if (batch.length > 2) {
                      i = j - 1; // skip them

                      return Column(
                        children: [
                          if (showDateDivider)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  formatDate(msg.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            widget.theme.colorScheme.tertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                              bottom: 2,
                            ),
                            child: ChatMessageItem(
                              message: batch.first,
                              isMe: isMe,
                              currentUserId: widget.currentUserId,
                              showTimestamp: true,
                              repliedMessage: repliedMessage,
                              batch: batch,
                              onSwipeMessage: widget.onSwipeMessage,
                              imageUrlsandFileName: _imagesUrlsandFileName,
                              handleReaction: (reaction, messageId) =>
                                  addReaction(
                                      messageId: messageId, reaction: reaction),
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  // 3. Fallback to your existing single‐message layout:
                  return Column(
                    children: [
                      if (showDateDivider)
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              formatDate(msg.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: widget.theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: showTimestamp ? 30 : 1,
                          bottom: 1,
                        ),
                        child: ChatMessageItem(
                          message: msg,
                          isMe: isMe,
                          currentUserId: widget.currentUserId,
                          showTimestamp: showTimestamp,
                          repliedMessage: repliedMessage,
                          onSwipeMessage: widget.onSwipeMessage,
                          imageUrlsandFileName: _imagesUrlsandFileName,
                          handleReaction: (reaction, messageId) => addReaction(
                              messageId: messageId, reaction: reaction),
                        ),
                      ),
                    ],
                  );
                }(),
              ],
            ],
          ),
        ),

        // Sticky date header
        if (_stickyDate != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _showSticky ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _stickyDate!,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _updateSticky(ScrollMetrics metrics) {
    // Approximate item height for index calculation
    const approxItemHeight = 80.0;
    final offset = metrics.pixels;
    final index = (offset / approxItemHeight).floor().clamp(
          0,
          widget.messages.length - 1,
        );
    final date = widget.messages[index].createdAt;
    final dateStr = formatDate(date);

    if (dateStr != _stickyDate || !_showSticky) {
      setState(() {
        _stickyDate = dateStr;
        _showSticky = true;
      });
    }

    // Fade out after a short delay
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _showSticky = false;
      });
    });
  }
}
