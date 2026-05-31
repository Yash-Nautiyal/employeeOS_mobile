import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/usecases/add_reaction.dart';
import '../../domain/usecases/create_conversation.dart';
import '../../domain/usecases/get_available_users.dart';
import '../../domain/usecases/listen_to_conversations.dart';
import '../../domain/usecases/listen_to_messages.dart';
import '../../domain/usecases/mark_conversation_as_read.dart';
import '../../domain/usecases/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ListenToConversationsUseCase listenToConversations;
  final ListenToMessagesUseCase listenToMessages;
  final SendMessageUseCase sendMessage;
  final AddReactionUseCase addReaction;
  final CreateConversationUseCase createConversation;
  final GetAvailableUsersUseCase getAvailableUsers;
  final MarkConversationAsReadUseCase markConversationAsRead;

  StreamSubscription? _inboxSubscription;
  StreamSubscription? _threadSubscription;

  ChatBloc({
    required this.listenToConversations,
    required this.listenToMessages,
    required this.sendMessage,
    required this.addReaction,
    required this.createConversation,
    required this.getAvailableUsers,
    required this.markConversationAsRead,
  }) : super(const ChatState()) {
    on<StartListeningConversationsEvent>(_onStartListeningConversations);
    on<_ConversationsUpdatedEvent>(_onConversationsUpdated);

    on<SelectConversationEvent>(_onSelectConversation);
    on<_ThreadUpdatedEvent>(_onThreadUpdated);

    on<SendMessageEvent>(_onSendMessage);
    on<AddReactionEvent>(_onAddReaction);
    on<CreateConversationEvent>(_onCreateConversation);

    on<LoadAvailableUsersEvent>(_onLoadAvailableUsers);
    on<ResetChatEvent>(_onResetChat);
    on<ClearSelectedConversationEvent>(
        _onClearSelectedConversation); // <--- Register it
  }

  void _onStartListeningConversations(
    StartListeningConversationsEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(status: ChatStatus.loading));

    // Cancel any previous subscription to prevent memory leaks
    _inboxSubscription?.cancel();

    // Listen to the stream and dispatch an internal event whenever data changes
    _inboxSubscription = listenToConversations(event.userId).listen(
      (result) => add(_ConversationsUpdatedEvent(result)),
    );
  }

  void _onResetChat(ResetChatEvent event, Emitter<ChatState> emit) {
    // 1. Stop listening to Supabase to save data/battery
    _inboxSubscription?.cancel();
    _threadSubscription?.cancel();

    // 2. Wipe the state completely clean
    emit(const ChatState());
  }

  void _onConversationsUpdated(
    _ConversationsUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    event.result.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.error,
        lastAction:
            ChatUIAction(type: UIActionType.error, message: failure.message),
      )),
      (conversations) => emit(state.copyWith(
        conversations: conversations,
        status: ChatStatus.loaded,
      )),
    );
  }

  void _onClearSelectedConversation(
    ClearSelectedConversationEvent event,
    Emitter<ChatState> emit,
  ) {
    _threadSubscription?.cancel(); // Stop listening to old thread
    emit(state.copyWith(
        clearSelection: true)); // Use the copyWith flag we added earlier
  }

  void _onSelectConversation(
    SelectConversationEvent event,
    Emitter<ChatState> emit,
  ) {
    if (event.conversationId.isEmpty) return;

    final index =
        state.conversations.indexWhere((c) => c.id == event.conversationId);
    if (index == -1) return;

    final conv = state.conversations[index];

    emit(
        state.copyWith(status: ChatStatus.loading, selectedConversation: conv));
    _threadSubscription?.cancel();

    _threadSubscription = listenToMessages(event.conversationId).listen(
      (result) => add(_ThreadUpdatedEvent(result)),
    );

    markConversationAsRead(
        conversationId: event.conversationId, userId: event.currentUserId);
  }

  void _onThreadUpdated(
    _ThreadUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    event.result.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.error,
        lastAction:
            ChatUIAction(type: UIActionType.error, message: failure.message),
      )),
      (conversation) {
        final updatedConversations = state.conversations.map((c) {
          return c.id == conversation.id ? conversation : c;
        }).toList();
        emit(state.copyWith(
          conversations: updatedConversations,
          selectedConversation: conversation,
          status: ChatStatus.loaded,
        ));
      },
    );
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));

    final result = await createConversation(
      participantIds: event.participantIds,
      authorId: event.authorId,
      firstMessageText: event.firstMessageText,
      attachments: event.attachments,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.error,
        lastAction:
            ChatUIAction(type: UIActionType.error, message: failure.message),
      )),
      (newId) => emit(state.copyWith(
        status: ChatStatus.loaded,
        newlyCreatedConversationId: newId, // Sets the ID to trigger the router
      )),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await sendMessage(
      conversationId: event.conversationId,
      authorId: event.authorId,
      text: event.text,
      replyTo: event.replyTo,
      attachments: event.attachments,
    );

    result.fold(
      (failure) {
        print('Error sending message: ${failure.message}');
        emit(state.copyWith(
          lastAction:
              ChatUIAction(type: UIActionType.error, message: failure.message),
        ));
      },
      (_) {
        // Success! We don't need to manually reload data or emit a new state here
        // because the Supabase Postgres stream will detect the new message and
        // automatically trigger _onThreadUpdated and _onConversationsUpdated.
      },
    );
  }

  Future<void> _onAddReaction(
    AddReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await addReaction(
      conversationId: event.conversationId,
      messageId: event.messageId,
      emoji: event.emoji,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        lastAction:
            ChatUIAction(type: UIActionType.error, message: failure.message),
      )),
      (_) {
        // Handled by stream
      },
    );
  }

  Future<void> _onLoadAvailableUsers(
    LoadAvailableUsersEvent event,
    Emitter<ChatState> emit,
  ) async {
    // --- THE BLoC CACHE ---
    // If we already have users loaded in state, don't fetch them again!
    if (state.availableUsers.isNotEmpty) return;

    emit(state.copyWith(isLoadingUsers: true));

    final result = await getAvailableUsers(event.currentUserId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingUsers: false,
        lastAction: ChatUIAction(
            type: UIActionType.error, message: 'Failed to load users'),
      )),
      (users) => emit(state.copyWith(
        availableUsers: users,
        isLoadingUsers: false,
      )),
    );
  }

  @override
  Future<void> close() {
    // Clean up streams when the BLoC is destroyed
    _inboxSubscription?.cancel();
    _threadSubscription?.cancel();
    return super.close();
  }
}
