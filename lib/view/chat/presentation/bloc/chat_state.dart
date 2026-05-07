part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

sealed class ChatActionState extends ChatState {
  const ChatActionState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}


final class ChatErrorActionState extends ChatActionState {
  final String message;

  const ChatErrorActionState(this.message);

  @override
  List<Object> get props => [message];
}