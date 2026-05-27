import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/di/service_locator.dart';
import 'package:employeeos/core/index.dart' show showCustomToast;
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/view/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'layout/index.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthBloc>().state.currentProfile?.id ?? '';

    sl<ChatBloc>()
        .add(StartListeningConversationsEvent(userId: _currentUserId));
  }

  @override
  void dispose() {
    sl<ChatBloc>().add(const ResetChatEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: sl<ChatBloc>(),
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.lastAction != current.lastAction &&
            current.lastAction != null,
        listener: (context, state) {
          if (state.lastAction != null) {
            final action = state.lastAction!;
            if (action.type == UIActionType.success && action.message != null) {
              showCustomToast(
                context: context,
                title: 'Success',
                description: action.message!,
                type: ToastificationType.success,
              );
            } else if (action.type == UIActionType.error &&
                action.message != null) {
              showCustomToast(
                context: context,
                title: 'Error',
                description: action.message!,
                type: ToastificationType.error,
              );
            }
          }
          if (state.newlyCreatedConversationId != null) {
            print(
                "Newly created conversation ID: ${state.newlyCreatedConversationId}");
            // Instantly replace the /app/chat/new route with the real database thread
            AppChatThreadRoute(
              conversationId: state.newlyCreatedConversationId!,
              $extra: ChatThreadRouteExtra(
                conversation: null, // Let it fetch fresh from the DB/stream
                conversations: state.conversations,
                currentUserId: _currentUserId,
              ),
            ).pushReplacement(context);

            // Clear the flag so it doesn't trigger again
            context
                .read<ChatBloc>()
                .add(const SelectConversationEvent(conversationId: ''));
          }
        },
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.conversations != current.conversations ||
                    previous.selectedConversation !=
                        current.selectedConversation,
                builder: (context, state) {
                  if (state is ChatInitial ||
                      (state.status == ChatStatus.loading &&
                          state.conversations.isEmpty)) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.status == ChatStatus.error &&
                      state.conversations.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading conversations',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ChatBloc>().add(
                                    StartListeningConversationsEvent(
                                        userId: _currentUserId));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Data is loaded (or loading in the background while data exists)
                  final conversations = state.conversations;

                  return Layout(
                    selectedConversation: state.selectedConversation,
                    currentUserId: _currentUserId,
                    conversations: conversations,
                    onConversationTap: (conv) {
                      print("Conversation tapped: ${conv.id}");
                      context.read<ChatBloc>().add(
                          SelectConversationEvent(conversationId: conv.id));
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
