import 'package:employeeos/core/routing/app_routes.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/conversation_models.dart' show Conversation;
import '../widget/chat_nav.dart';
import 'landscape/chat_view_landscape.dart';

class Layout extends StatelessWidget {
  final Conversation? selectedConversation;
  final String currentUserId;
  final List<Conversation> conversations;
  final Function onConversationTap;
  const Layout(
      {super.key,
      required this.selectedConversation,
      required this.currentUserId,
      required this.conversations,
      required this.onConversationTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < constraints.maxHeight;
        if (!isPortrait) {
          return ThreadPageLandscape(
            selectedConversation: selectedConversation,
            currentUserId: currentUserId,
            conversations: conversations,
            onConversationTap: (conv) => onConversationTap(conv),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ChatNav(
                currentUserId: currentUserId,
                theme: theme,
                conversations: conversations,
                onConversationTap: (conv) {
                  onConversationTap(conv);
                  AppChatThreadRoute(
                    conversationId: conv.id,
                    $extra: ChatThreadRouteExtra(
                      conversation: conv,
                      conversations: conversations,
                      currentUserId: currentUserId,
                    ),
                  ).push(context);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
