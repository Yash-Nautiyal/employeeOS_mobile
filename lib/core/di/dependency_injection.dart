import 'package:supabase_flutter/supabase_flutter.dart';

import 'service_locator.dart';
import '../../view/chat/data/datasources/chat_remote_datasource.dart';
import '../../view/chat/data/repository/chat_repository_impl.dart';

import '../../view/chat/domain/repositories/chat_repository.dart';

import '../../view/chat/domain/usecases/get_available_users.dart';
import '../../view/chat/domain/usecases/create_conversation.dart';
import '../../view/chat/domain/usecases/add_reaction.dart';
import '../../view/chat/domain/usecases/listen_to_conversations.dart';
import '../../view/chat/domain/usecases/listen_to_messages.dart';
import '../../view/chat/domain/usecases/send_message.dart';

import '../../view/chat/presentation/bloc/chat_bloc.dart';

Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // 1. Core / External
  // ---------------------------------------------------------------------------
  // Register the Supabase client as a singleton so the same connection is reused.
  ServiceLocator.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // ---------------------------------------------------------------------------
  // 2. Chat Feature Integration
  // ---------------------------------------------------------------------------

  // Data Sources
  ServiceLocator.registerSingleton<ChatRemoteDataSource>(
    ChatRemoteDataSourceImpl(supabase: sl<SupabaseClient>()),
  );

  // Repositories
  ServiceLocator.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()),
  );

  // Use Cases (Registered as singletons because they hold no state)
  ServiceLocator.registerSingleton<ListenToConversationsUseCase>(
    ListenToConversationsUseCase(sl<ChatRepository>()),
  );
  ServiceLocator.registerSingleton<ListenToMessagesUseCase>(
    ListenToMessagesUseCase(sl<ChatRepository>()),
  );
  ServiceLocator.registerSingleton<SendMessageUseCase>(
    SendMessageUseCase(sl<ChatRepository>()),
  );
  ServiceLocator.registerSingleton<AddReactionUseCase>(
    AddReactionUseCase(sl<ChatRepository>()),
  );
  ServiceLocator.registerSingleton<CreateConversationUseCase>(
    CreateConversationUseCase(sl<ChatRepository>()),
  );
  ServiceLocator.registerSingleton<GetAvailableUsersUseCase>(
    GetAvailableUsersUseCase(sl<ChatRepository>()),
  );

  // BLoC (Registered as a SINGLETON)
  // We use a Singleton so the Portrait router and Landscape split-view share the exact same state.
  // Memory leaks are prevented by manually firing ResetChatEvent when ChatView is disposed.
  ServiceLocator.registerSingleton<ChatBloc>(
    ChatBloc(
      listenToConversations: sl<ListenToConversationsUseCase>(),
      listenToMessages: sl<ListenToMessagesUseCase>(),
      createConversation: sl<CreateConversationUseCase>(),
      sendMessage: sl<SendMessageUseCase>(),
      addReaction: sl<AddReactionUseCase>(),
      getAvailableUsers: sl<GetAvailableUsersUseCase>(),
    ),
  );
}
