import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation;
import 'package:employeeos/view/chat/presentation/widget/chat_app_bar.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_input.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_media_preview.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_message_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class ThreadPage extends StatefulWidget {
  final Conversation selectedConversation;
  const ThreadPage({super.key, required this.selectedConversation});

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late bool sidebar;
  final String _currentUserId = 'user-123'; // replace with real user ID
  // ignore: prefer_final_fields
  ChatMessage? replyMessage;

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
    final newMsg = TextMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
      replyTo: replyMessage?.id,
    );
    setState(() {
      widget.selectedConversation.messages.insert(0, newMsg);
      replyMessage = null;
    });
  }

  /// Pick an image file and show preview
  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result == null) return;

    final mediaItems = result.files
        .where((file) => file.path != null)
        .map((file) => MediaPreviewItem(
              path: file.path!,
              name: file.name,
              size: file.size,
            ))
        .toList();

    if (mediaItems.isEmpty) return;

    _showMediaPreview(mediaItems);
  }

  /// Pick any file and show preview
  Future<void> _handlePickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null) return;

    final mediaItems = result.files
        .where((file) => file.path != null)
        .map((file) => MediaPreviewItem(
              path: file.path!,
              name: file.name,
              size: file.size,
            ))
        .toList();

    if (mediaItems.isEmpty) return;

    _showMediaPreview(mediaItems);
  }

  /// Show media preview bottom sheet
  void _showMediaPreview(List<MediaPreviewItem> mediaItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        onCancel: () => Navigator.pop(context),
        onSend: (items) {
          Navigator.pop(context);
          _handleMediaSend(items);
        },
      ),
    );
  }

  /// Send media messages after preview confirmation
  void _handleMediaSend(List<MediaPreviewItem> items) {
    final newMessages = items.map((item) {
      final mimeType = lookupMimeType(item.path) ?? 'application/octet-stream';
      final isImage = mimeType.startsWith('image/');

      if (isImage) {
        return ImageMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: _currentUserId,
          createdAt: DateTime.now(),
          url: item.path,
          name: item.name,
          size: item.size,
          replyTo: replyMessage?.id,
        );
      } else {
        return FileMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: _currentUserId,
          createdAt: DateTime.now(),
          url: item.path,
          name: item.name,
          size: item.size,
          fileType: mimeType,
        );
      }
    }).toList();

    setState(() {
      // insert at front so that with reverse:true it appears at the bottom
      widget.selectedConversation.messages.insertAll(0, newMessages);
      replyMessage = null; // Clear the reply message after sending
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          ChatAppBar(
            theme: theme,
            currentUserId: _currentUserId,
            subTitle: "Online",
            conversation: widget.selectedConversation,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ChatMessageList(
                participants: widget.selectedConversation.participants,
                messages: widget.selectedConversation.messages,
                currentUserId: _currentUserId,
                onSwipeMessage: handleSwipeMessage,
                theme: theme),
          ),
          const SizedBox(
            height: 20,
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 10),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChatInput(
              theme: theme,
              onSendText: (text) => _handleTextSend(text),
              onPickImage: _handlePickImage,
              onPickFile: _handlePickFile,
              onCancelReply: _cancelReply,
              replyMessage: replyMessage,
              currentUserId: _currentUserId,
            ),
          ),
        ],
      ),
    );
  }
}
