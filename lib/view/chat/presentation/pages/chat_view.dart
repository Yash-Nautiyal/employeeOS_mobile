import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show
        ChatMessage,
        FileMessage,
        ImageMessage,
        TextMessage,
        getMockChatMessages;
import 'package:employeeos/view/chat/presentation/widget/chat_app_bar.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_input.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_message_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool sidebar;
  final String _currentUserId = 'user-123'; // replace with real user ID
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    sidebar = false;
    _messages = getMockChatMessages(currentUserId: _currentUserId);
  }

  void _handleSend(String text) {
    final newMsg = TextMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
    );
    setState(() {
      // insert at front so that with reverse:true it appears at the bottom
      _messages.insert(0, newMsg);
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
      );
    }).toList();

    setState(() => _messages.insertAll(0, newMessages));
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

    setState(() => _messages.insertAll(0, newMessages));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0)
            .copyWith(top: 100, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat",
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatAppBar(theme: theme),
                      Expanded(
                        child: ChatMessageList(
                            messages: _messages,
                            currentUserId: _currentUserId,
                            theme: theme),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ChatInput(
                          theme: theme,
                          onSendText: (text) => _handleSend(text),
                          onPickImage: _handlePickImage,
                          onPickFile: _handlePickFile,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
