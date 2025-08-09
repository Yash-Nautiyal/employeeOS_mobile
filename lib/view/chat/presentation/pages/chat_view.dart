import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show ChatMessage, FileMessage, ImageMessage, TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_app_bar.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_input.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_message_list.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool sidebar;
  final String _currentUserId = 'user-123'; // replace with real user ID
  // ignore: prefer_final_fields
  ChatMessage? replyMessage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Conversation> _conversations;
  Conversation? _selectedConversation;

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _conversations = [
      Conversation(
        id: '11',
        name: 'Simon Freshman 1',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(const Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 2)),
              text: 'I am fine, thanks!'),
        ],
      ),
      Conversation(
        id: '12',
        name: 'Simon Freshman 5',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(const Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 2)),
              text: 'I am fine, thanks!'),
        ],
      ),
      Conversation(
        id: '13',
        name: 'Simon Freshman 4',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(const Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 2)),
              text: 'I am fine, thanks!'),
        ],
      ),
      Conversation(
        id: '14',
        name: 'Simon Freshman 3',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(const Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 2)),
              text: 'I am fine, thanks!'),
        ],
      ),
      Conversation(
        id: '15',
        name: 'Simon Freshman 2',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(const Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(minutes: 2)),
              text: 'I am fine, thanks!'),
        ],
      ),
      Conversation(
        id: '2',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '2',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '21',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '22',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '23',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '24',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
      Conversation(
        id: '25',
        name: 'Alice Johnson',
        messages: [
          TextMessage(
              id: '4',
              authorId: _currentUserId,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              text: 'Morning!'),
        ],
      ),
    ];
    for (var conversation in _conversations) {
      conversation.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    _selectedConversation = null;
  }

  void _handleTextSend(String text) {
    if (_selectedConversation == null) return;
    final newMsg = TextMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
      replyTo: replyMessage?.id,
    );
    setState(() {
      _selectedConversation!.messages.insert(0, newMsg);
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
      _selectedConversation!.messages.insertAll(0, newMessages);
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

    setState(() => _selectedConversation!.messages.insertAll(0, newMessages));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _selectedConversation != null
                    ? ChatAppBar(
                        theme: theme,
                        name: _selectedConversation?.name ?? "",
                        subTitle: "Online",
                        avatar: _selectedConversation?.name[0] ?? "C",
                        onBack: () => setState(() {
                          _selectedConversation = null;
                        }),
                      )
                    : const SizedBox.shrink(),
                _selectedConversation == null
                    ? Expanded(
                        child: ChatNav(
                          theme: Theme.of(context),
                          conversations: _conversations,
                          onConversationTap: (conv) {
                            setState(() {
                              _selectedConversation = conv;
                            });
                          },
                        ),
                      )
                    : Expanded(
                        child: _selectedConversation == null
                            ? Center(
                                child: Text('No conversation selected',
                                    style: theme.textTheme.bodyMedium))
                            : ChatMessageList(
                                messages: _selectedConversation!.messages,
                                currentUserId: _currentUserId,
                                onSwipeMessage: handleSwipeMessage,
                                theme: theme),
                      ),
                _selectedConversation != null
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: ChatInput(
                          theme: theme,
                          onSendText: (text) => _handleTextSend(text),
                          onPickImage: _handlePickImage,
                          onPickFile: _handlePickFile,
                          onCancelReply: _cancelReply,
                          replyMessage: replyMessage,
                          currentUserId: _currentUserId,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
