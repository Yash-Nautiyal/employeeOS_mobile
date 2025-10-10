import 'package:animations/animations.dart'
    show SharedAxisTransition, SharedAxisTransitionType;
import 'package:employeeos/view/chat/data/test_data.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/pages/thread_page.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String _currentUserId = 'user-123';
  final _chatNavKey = GlobalKey<NavigatorState>();

  Future<bool> _onWillPop() async {
    // If thread is open, pop it first (WhatsApp behavior)
    if (_chatNavKey.currentState?.canPop() == true) {
      _chatNavKey.currentState!.pop();
      return false;
    }
    return true; // let parent handle (switching sections, etc.)
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: Wrap in WillPopScope so back pops the thread first
    return WillPopScope(
      onWillPop: _onWillPop,
      child: HeroControllerScope(
        // enables Hero inside nested navigator
        controller: MaterialApp.createMaterialHeroController(),
        child: Navigator(
          key: _chatNavKey,
          initialRoute: '/conversations',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/conversations':
                return _sharedAxisRoute(
                  ChatPage(
                    currentUserId: _currentUserId,
                  ),
                  settings: settings,
                );
              case '/thread':
                final conv = settings.arguments as Conversation;
                return _sharedAxisRoute(
                  ThreadPage(selectedConversation: conv),
                  settings: settings,
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => ChatPage(
                    currentUserId: _currentUserId,
                  ),
                  settings: settings,
                );
            }
          },
        ),
      ),
    );
  }
}

PageRoute _sharedAxisRoute(Widget child, {RouteSettings? settings}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

class ChatPage extends StatefulWidget {
  final String currentUserId;
  const ChatPage({super.key, required this.currentUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late List<Conversation> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = testConversations;
    for (var conversation in _conversations) {
      conversation.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ChatNav(
                    currentUserId: widget.currentUserId,
                    theme: theme,
                    conversations: _conversations,
                    onConversationTap: (conv) {
                      Navigator.of(context)
                          .pushNamed('/thread', arguments: conv);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
