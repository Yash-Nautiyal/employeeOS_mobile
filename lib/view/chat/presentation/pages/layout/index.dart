import 'package:employeeos/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/conversation.dart' show Conversation;
import '../../bloc/chat_bloc.dart';
import '../../widget/nav/chat_nav.dart';
import '../thread_page_landscape.dart';

class Layout extends StatefulWidget {
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
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  bool _isTransitioningToPortraitThread = false;

  @override
  Widget build(BuildContext context) {
    // print("Selected conversation: ${widget.selectedConversation}");
    final theme = Theme.of(context);
    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < constraints.maxHeight;
        // --- AUTO-PUSH TO PORTRAIT ROUTE ---
        if (isPortrait &&
            widget.selectedConversation != null &&
            !_isTransitioningToPortraitThread) {
          _isTransitioningToPortraitThread = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppChatThreadRoute(
                conversationId: widget.selectedConversation!.id,
                $extra: ChatThreadRouteExtra(
                  conversation: widget.selectedConversation,
                  conversations: widget.conversations,
                  currentUserId: widget.currentUserId,
                ),
              ).push(context).then(
                (_) {
                  if (mounted) {
                    _isTransitioningToPortraitThread = false;
                    // context
                    //     .read<ChatBloc>()
                    //     .add(const ClearSelectedConversationEvent());
                  }
                },
              );
            }
          });
        }

        if (!isPortrait) {
          _isTransitioningToPortraitThread = false;
          return ThreadPageLandscape(
            selectedConversation: widget.selectedConversation,
            currentUserId: widget.currentUserId,
            conversations: widget.conversations,
            onConversationTap: (conv) => widget.onConversationTap(conv),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ChatNav(
                currentUserId: widget.currentUserId,
                theme: theme,
                conversations: widget.conversations,
                onNewChatLandscape: () => context
                    .read<ChatBloc>()
                    .add(const ClearSelectedConversationEvent()),
                onConversationTap: (conv) {
                  widget.onConversationTap(conv);
                  _isTransitioningToPortraitThread = true;
                  AppChatThreadRoute(
                    conversationId: conv.id,
                    $extra: ChatThreadRouteExtra(
                      conversation: conv,
                      conversations: widget.conversations,
                      currentUserId: widget.currentUserId,
                    ),
                  ).push(context).then((_) {
                    if (mounted) {
                      _isTransitioningToPortraitThread = false;
                      context.read<ChatBloc>().add(
                          const SelectConversationEvent(conversationId: ''));
                    }
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
