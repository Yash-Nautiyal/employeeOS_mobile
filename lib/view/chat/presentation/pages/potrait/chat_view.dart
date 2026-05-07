import 'package:employeeos/core/index.dart' show showCustomToast;
import 'package:employeeos/view/chat/data/test_data.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../layout.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String _currentUserId = 'user-123';
  late final List<Conversation> _conversations;
  late final ChatBloc _chatBloc;
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
    _chatBloc.add(ChatLoadingEvent());
    _conversations = testConversations;
    for (final conversation in _conversations) {
      conversation.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => _chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) => current is ChatActionState,
        listener: (context, state) {
          if (state is ChatErrorActionState) {
            showCustomToast(
              context: context,
              type: ToastificationType.error,
              title: 'Error',
              description: state.message,
            );
          }
        },
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) => current is! ChatActionState,
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return Layout(
                      selectedConversation: _selectedConversation,
                      currentUserId: _currentUserId,
                      conversations: _conversations,
                      onConversationTap: (conv) {
                        setState(() {
                          _selectedConversation = conv;
                        });
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
