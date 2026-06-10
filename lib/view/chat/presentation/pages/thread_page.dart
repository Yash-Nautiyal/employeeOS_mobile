import 'dart:io';

import 'package:employeeos/core/index.dart';
import 'package:employeeos/view/chat/data/models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart'
    show Conversation, ConversationType;
import '../bloc/chat_bloc.dart';
import '../widget/appbar/chat_app_bar.dart';
import '../widget/input/chat_input.dart';
import '../widget/preview/chat_media_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_message_list.dart';

import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/participant.dart';

class ThreadPage extends StatefulWidget {
  final Conversation? selectedConversation;
  final String? conversationId;
  final List<Conversation>? conversations;
  final String currentUserId;
  final Function onConversationTap;
  final bool isEmbedded;

  const ThreadPage({
    super.key,
    required this.selectedConversation,
    this.conversationId,
    this.conversations,
    required this.currentUserId,
    required this.onConversationTap,
    this.isEmbedded = false,
  });

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  ChatMessage? replyMessage;
  late final String _currentUserId;
  Participant? _selectedNewParticipant;

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.currentUserId;

    final targetId = _targetConversationId;
    if (targetId != null && targetId != 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ChatBloc>().add(SelectConversationEvent(
              conversationId: targetId,
              currentUserId: _currentUserId,
            ));
      });
    }
  }

  String? get _targetConversationId =>
      widget.conversationId ?? widget.selectedConversation?.id;

  void _onConversationCreated(BuildContext context, ChatState state) {
    final newId = state.newlyCreatedConversationId;
    if (newId == null) return;

    context.read<ChatBloc>().add(SelectConversationEvent(
          conversationId: newId,
          currentUserId: _currentUserId,
        ));
    context.read<ChatBloc>().add(const ClearNewlyCreatedConversationIdEvent());

    if (!widget.isEmbedded) {
      AppChatThreadRoute(
        conversationId: newId,
        $extra: ChatThreadRouteExtra(
          conversation: null,
          conversations: state.conversations,
          currentUserId: _currentUserId,
        ),
      ).pushReplacement(context);
    }
  }

  void handleSwipeMessage(ChatMessage message) {
    setState(() {
      replyMessage = message;
    });
  }

  void _cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  void _handleTextSend(String text) {
    // If we already have a conversation, send normally
    if (widget.selectedConversation != null) {
      context.read<ChatBloc>().add(SendMessageEvent(
            conversationId: widget.selectedConversation!.id,
            authorId: _currentUserId,
            text: text,
            replyTo: replyMessage?.dbId,
          ));
    }
    // If no conversation exists yet, create one!
    else if (_selectedNewParticipant != null) {
      // You will need to add this event to your BLoC (details below)
      context.read<ChatBloc>().add(CreateConversationEvent(
            participantIds: [_selectedNewParticipant!.id],
            authorId: _currentUserId,
            firstMessageText: text, // The message they just typed
          ));
    }

    setState(() {
      replyMessage = null;
    });
  }

  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result == null) return;

    final mediaItems = result.files
        .where((file) => file.path != null)
        .map((file) => MediaPreviewItem(
            path: file.path!, name: file.name, size: file.size))
        .toList();

    if (mediaItems.isNotEmpty) _showMediaPreview(mediaItems);
  }

  Future<void> _handlePickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: true);
    if (result == null) return;

    final mediaItems = result.files
        .where((file) => file.path != null)
        .map((file) => MediaPreviewItem(
            path: file.path!, name: file.name, size: file.size))
        .toList();

    if (mediaItems.isNotEmpty) _showMediaPreview(mediaItems);
  }

  void _showMediaPreview(List<MediaPreviewItem> mediaItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppPallete.black
          : AppPallete.white,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (context) => ChatMediaPreview(
        mediaItems: mediaItems,
        theme: Theme.of(context),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
        onSend: (items, caption) {
          Navigator.of(context, rootNavigator: true).pop();
          _handleMediaSend(items, caption);
        },
      ),
    );
  }

  void _handleMediaSend(List<MediaPreviewItem> items, String caption) {
    final files = items.map((item) => File(item.path)).toList();
    final textToSend = caption.isNotEmpty ? caption : null;
    // SCENARIO A: The conversation already exists
    if (widget.selectedConversation != null) {
      context.read<ChatBloc>().add(SendMessageEvent(
            conversationId: widget.selectedConversation!.id,
            authorId: _currentUserId,
            attachments: files,
            replyTo: replyMessage?.dbId,
            text: textToSend,
          ));
    }
    // SCENARIO B: Brand new conversation, initiated by an attachment!
    else if (_selectedNewParticipant != null) {
      context.read<ChatBloc>().add(CreateConversationEvent(
            participantIds: [_selectedNewParticipant!.id],
            authorId: _currentUserId,
            firstMessageText: textToSend, // No text, just the files!
            attachments: files,
          ));
    }

    setState(() {
      replyMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // --- AUTO-POP LOGIC ---
    if (!widget.isEmbedded && !isPortrait) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor);
    }

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.newlyCreatedConversationId !=
              current.newlyCreatedConversationId &&
          current.newlyCreatedConversationId != null,
      listener: _onConversationCreated,
      child: Container(
        padding: EdgeInsets.only(
            top: isPortrait ? MediaQuery.of(context).padding.top : 10),
        color: theme.scaffoldBackgroundColor,
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final String? targetId = _targetConversationId;
            final isNewChat = targetId == null || targetId == 'new';
          ParticipantStatus? status;
          Conversation? liveConversation;
          if (!isNewChat) {
            if (state.selectedConversation?.id == targetId) {
              liveConversation = state.selectedConversation;
            } else {
              final index =
                  state.conversations.indexWhere((c) => c.id == targetId);
              liveConversation = index != -1
                  ? state.conversations[index]
                  : widget.selectedConversation;
            }
            status = liveConversation?.type == ConversationType.oneToOne
                ? liveConversation?.participants
                    .firstWhere(
                      (p) => p.id != _currentUserId,
                    )
                    .status
                : null;
          }
          // log(jsonEncode(
          //     ConversationModel.toJSON(liveConversation!)["messages"]));

          return Column(
            children: [
              ChatAppBar(
                theme: theme,
                currentUserId: _currentUserId,
                status: status,
                conversation: liveConversation, // <-- Pass the live one here
                availableUsers: state.availableUsers,
                isLoadingUsers: state.isLoadingUsers,
                onSelectUser: (value) {
                  final existingConversation =
                      widget.conversations?.cast<Conversation?>().firstWhere(
                    (conv) {
                      if (conv == null) return false;
                      final isOneToOne = conv.type == ConversationType.oneToOne;
                      final hasUser =
                          conv.participants.any((p) => p.id == value.id);
                      return isOneToOne && hasUser;
                    },
                    orElse: () => null,
                  );

                  if (existingConversation != null) {
                    AppChatThreadRoute(
                      conversationId: existingConversation.id,
                      $extra: ChatThreadRouteExtra(
                        conversation: existingConversation,
                        conversations: widget.conversations,
                        currentUserId: _currentUserId,
                      ),
                    ).pushReplacement(context);
                  } else {
                    setState(() {
                      _selectedNewParticipant = value;
                    });
                  }
                },
                onBack: () {
                  context
                      .read<ChatBloc>()
                      .add(const ClearSelectedConversationEvent());
                  if (!widget.isEmbedded) {
                    Navigator.of(context).pop();
                  }
                },
                isNewChat: isNewChat,
              ),
              if (liveConversation != null ||
                  _selectedNewParticipant != null) ...[
                Expanded(
                  child: liveConversation == null
                      ? const EmptyContent(
                          icon: 'assets/icons/empty/ic-chat-active.svg',
                          title: 'No Messages',
                          description:
                              'Type your first message to start chatting',
                        )
                      : ChatMessageList(
                          conversationId: liveConversation.id,
                          participants: liveConversation.participants,
                          messages: liveConversation.messages.reversed.toList(),
                          currentUserId: _currentUserId,
                          onSwipeMessage: handleSwipeMessage,
                          theme: theme,
                        ),
                ),
                const SizedBox(height: 20),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 10),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ChatInput(
                    theme: theme,
                    onSendText: _handleTextSend,
                    onPickImage: _handlePickImage,
                    onPickFile: _handlePickFile,
                    onCancelReply: _cancelReply,
                    replyMessage: replyMessage,
                    currentUserId: _currentUserId,
                    participants: liveConversation?.participants ?? [],
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: EmptyContent(
                    icon: 'assets/icons/empty/ic-folder-empty.svg',
                    title: 'No conversation selected',
                  ),
                ),
              ]
            ],
          );
          },
        ),
      ),
    );
  }
}
