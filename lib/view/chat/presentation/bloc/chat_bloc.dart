import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatLoadingEvent>(_onChatLoadingEvent);
  }

  static FutureOr<void> _onChatLoadingEvent(
      ChatLoadingEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await Future.delayed(const Duration(seconds: 2));

    emit(const ChatErrorActionState('Error loading chat'));
    emit(ChatLoaded());
  }
}
