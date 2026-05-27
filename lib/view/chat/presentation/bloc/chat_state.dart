part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, error }

enum UIActionType { success, error }

class ChatUIAction extends Equatable {
  final UIActionType type;
  final String? message;
  final int _timestamp;

  ChatUIAction({required this.type, this.message})
      : _timestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [type, message, _timestamp];
}

final class ChatInitial extends ChatState {}

final class ChatState extends Equatable {
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final ChatStatus status;
  final ChatUIAction? lastAction;
  final String? newlyCreatedConversationId;

  // --- User State ---
  final List<Participant> availableUsers;
  final bool isLoadingUsers;

  const ChatState({
    this.conversations = const [],
    this.selectedConversation,
    this.status = ChatStatus.initial,
    this.lastAction,
    this.newlyCreatedConversationId,
    this.availableUsers = const [],
    this.isLoadingUsers = false,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    ChatStatus? status,
    ChatUIAction? lastAction,
    String? newlyCreatedConversationId,
    List<Participant>? availableUsers,
    bool? isLoadingUsers,
    bool clearSelection = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearSelection
          ? null
          : (selectedConversation ?? this.selectedConversation),
      status: status ?? this.status,
      lastAction: lastAction ?? this.lastAction,
      newlyCreatedConversationId: newlyCreatedConversationId,
      availableUsers: availableUsers ?? this.availableUsers,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        selectedConversation,
        status,
        lastAction,
        newlyCreatedConversationId,
        availableUsers,
        isLoadingUsers,
      ];
}
