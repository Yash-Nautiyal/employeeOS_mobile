import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation;
import 'package:employeeos/view/chat/presentation/widget/chat_app_bar.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_input.dart';
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

  /// Pick an image file and insert an ImageMessage
  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result == null) return;

    final newMessages = result.files.map((file) {
      final filePath = file.path!;
      return ImageMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: _currentUserId,
        createdAt: DateTime.now(),
        url: filePath,
        name: file.name,
        size: file.size,
        replyTo: replyMessage?.id,
      );
    }).toList();

    setState(() {
      // insert at front so that with reverse:true it appears at the bottom
      widget.selectedConversation.messages.insertAll(0, newMessages);
      replyMessage = null; // Clear the reply message after sending
    });
  }

  /// Pick any file and insert a FileMessage
  Future<void> _handlePickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );
    if (result == null) return;

    final newMessages = result.files.map((file) {
      final filePath = file.path!;
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      return FileMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: _currentUserId,
        createdAt: DateTime.now(),
        url: filePath,
        name: file.name,
        size: file.size,
        fileType: mimeType,
      );
    }).toList();

    setState(
        () => widget.selectedConversation.messages.insertAll(0, newMessages));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
            ChatInput(
              theme: theme,
              onSendText: (text) => _handleTextSend(text),
              onPickImage: _handlePickImage,
              onPickFile: _handlePickFile,
              onCancelReply: _cancelReply,
              replyMessage: replyMessage,
              currentUserId: _currentUserId,
            ),
          ],
        ),
      ),
    );
  }
}
