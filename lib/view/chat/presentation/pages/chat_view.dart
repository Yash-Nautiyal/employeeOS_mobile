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
        id: '1',
        name: 'Simon Freshman',
        messages: [
          TextMessage(
              id: '1',
              authorId: _currentUserId,
              createdAt: now.subtract(Duration(minutes: 5)),
              text: 'Hey there!'),
          TextMessage(
              id: '2',
              authorId: 'user_2',
              createdAt: now.subtract(Duration(minutes: 4)),
              text: 'Hello, how are you?'),
          TextMessage(
              id: '3',
              authorId: _currentUserId,
              createdAt: now.subtract(Duration(minutes: 2)),
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
              createdAt: now.subtract(Duration(hours: 1, minutes: 15)),
              text: 'Good morning'),
          TextMessage(
              id: '5',
              authorId: 'user_3',
              createdAt: now.subtract(Duration(hours: 1, minutes: 10)),
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
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 20),
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
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChatAppBar(
                          theme: theme,
                          name: _selectedConversation?.name ?? "",
                          subTitle: "Online",
                          avatar: _selectedConversation?.name[0] ?? "C",
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              _selectedConversation == null
                                  ? Center(
                                      child: Text('No conversation selected',
                                          style: theme.textTheme.bodyMedium))
                                  : ChatMessageList(
                                      messages: _selectedConversation!.messages,
                                      currentUserId: _currentUserId,
                                      onSwipeMessage: handleSwipeMessage,
                                      theme: theme),
                              Positioned(
                                top: 15,
                                child: GestureDetector(
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: "ChatNav",
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        );
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(-1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(curvedAnimation),
                                          child: child,
                                        );
                                      },
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.65,
                                            child: Material(
                                              color:
                                                  theme.scaffoldBackgroundColor,
                                              elevation: 8,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(16),
                                                  bottomRight:
                                                      Radius.circular(16),
                                                ),
                                              ),
                                              child: ChatNav(
                                                theme: Theme.of(context),
                                                conversations: _conversations,
                                                onConversationTap: (conv) {
                                                  setState(() {
                                                    _selectedConversation =
                                                        conv;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      color: AppPallete.primaryMain,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
                                      color: AppPallete.white,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
