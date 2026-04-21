import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/view/chat/data/test_data.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/pages/chat_view_landscape.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String _currentUserId = 'user-123';
  late final List<Conversation> _conversations;
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _conversations = testConversations;
    for (final conversation in _conversations) {
      conversation.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isPortrait
              ? Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ChatNav(
                          currentUserId: _currentUserId,
                          theme: theme,
                          conversations: _conversations,
                          onConversationTap: (conv) {
                            setState(() {
                              _selectedConversation = conv;
                            });
                            AppChatThreadRoute(
                              conversationId: conv.id,
                              $extra: ChatThreadRouteExtra(
                                conversation: conv,
                                conversations: _conversations,
                                currentUserId: _currentUserId,
                              ),
                            ).push(context);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: ThreadPageLandscape(
                    selectedConversation: _selectedConversation,
                    currentUserId: _currentUserId,
                    conversations: _conversations,
                    onConversationTap: (conv) {
                      setState(() {
                        _selectedConversation = conv;
                      });
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
