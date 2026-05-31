import 'dart:async';
import 'dart:io';

import 'package:employeeos/core/index.dart' show UserInfoService;
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/participant.dart'
    show Participant, ParticipantStatus;
import '../models/conversation_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  Stream<List<ConversationModel>> listenToConversations(String userId);
  Future<ConversationModel> getConversationById(String conversationId);
  Stream<ConversationModel> listenToMessages(String conversationId);
  Future<List<Participant>> getAvailableUsers(String currentUserId);

  Future<String> createConversation({
    required List<String> participantIds,
    required String authorId,
    String? firstMessageText,
    List<File>? attachments,
    bool isGroup = false,
    String? groupName,
  });

  Future<void> sendMessage({
    required String conversationId,
    required String authorId,
    String? text,
    String? replyTo,
    List<File>? attachments,
  });

  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  });

  Future<void> markConversationAsRead(String conversationId, String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabase;

  ChatRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final response = await supabase.rpc(
      'get_user_conversations',
      params: {'p_user_id': userId},
    );

    final List<dynamic> data = response as List<dynamic>;

    return data
        .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<ConversationModel>> listenToConversations(String userId) {
    late StreamController<List<ConversationModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      try {
        final conversations = await getConversations(userId);
        if (!controller.isClosed) {
          controller.add(conversations);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<List<ConversationModel>>(
      onListen: () {
        fetchAndEmit(); // Initial fetch

        channel = supabase.channel('inbox_updates_$userId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) => fetchAndEmit(),
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'attachments',
            callback: (payload) => fetchAndEmit(),
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'chat_notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => fetchAndEmit(),
          )
          ..subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<ConversationModel> getConversationById(String conversationId) async {
    final response = await supabase.rpc(
      'get_conversation_by_id',
      params: {'p_conversation_id': conversationId},
    );

    if (response == null) {
      throw Exception('Conversation not found');
    }

    return ConversationModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Stream<ConversationModel> listenToMessages(String conversationId) {
    late StreamController<ConversationModel> controller;
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      print('Fetching conversation $conversationId due to change ');
      try {
        final conversation = await getConversationById(conversationId);
        if (!controller.isClosed) {
          controller.add(conversation);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<ConversationModel>(
      onListen: () {
        fetchAndEmit();

        channel = supabase.channel('thread_$conversationId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationId,
            ),
            callback: (payload) => fetchAndEmit(),
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'message_reactions',
            callback: (payload) {
              print('Got reaction change: $payload');
              fetchAndEmit();
            }, // Emits on reaction changes
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'attachments',
            callback: (payload) => fetchAndEmit(),
          )
          ..subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Participant>> getAvailableUsers(String currentUserId) async {
    final allusers = await UserInfoService().fetchAllUsers();

    // Map them directly into your clean Participant models here in the data layer!
    return allusers.where((user) => user.id != currentUserId).map((user) {
      ParticipantStatus status = ParticipantStatus.offline;
      switch (user.status?.toLowerCase()) {
        case 'online':
          status = ParticipantStatus.online;
          break;
        case 'away':
          status = ParticipantStatus.away;
          break;
        case 'busy':
          status = ParticipantStatus.busy;
          break;
      }

      return Participant(
        id: user.id,
        name: user.fullName,
        status: status,
        avatarUrl: user.avatarUrl ?? '',
      );
    }).toList();
  }

  @override
  Future<String> createConversation({
    required List<String> participantIds,
    required String authorId,
    String? firstMessageText,
    List<File>? attachments,
    bool isGroup = false,
    String? groupName,
  }) async {
    // 1. Create the conversation record
    final convRes = await supabase
        .from('conversations')
        .insert({
          'is_group': isGroup,
          'name': groupName,
        })
        .select('id')
        .single();

    final String conversationId = convRes['id'].toString();

    // 2. Add group details if it's a group chat
    if (isGroup) {
      await supabase.from('groups').insert({
        'conversation_id': conversationId,
        'group_name': groupName,
      });
    }

    // 3. Add all participants (ensure the author is included)
    final Set<String> allParticipants = {...participantIds, authorId};
    final participantData = allParticipants
        .map((id) => {
              'conversation_id': conversationId,
              'participant_id': id,
            })
        .toList();

    await supabase.from('conversation_participants').insert(participantData);

    // 4. Send the first message (Reuses your existing method which handles attachments!)
    await sendMessage(
      conversationId: conversationId,
      authorId: authorId,
      text: firstMessageText,
      attachments: attachments,
    );

    return conversationId; // Return ID so UI can route to it
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String authorId,
    String? text,
    String? replyTo,
    List<File>? attachments,
  }) async {
    final uploadedAttachments = <Map<String, dynamic>>[];

    if (attachments != null && attachments.isNotEmpty) {
      for (final file in attachments) {
        final fileName = path.basename(file.path);
        final fileExt = path.extension(file.path).replaceAll('.', '');
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';

        final storagePath =
            '$conversationId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await supabase.storage.from('chat_attachment').upload(
              storagePath,
              file,
              fileOptions: FileOptions(contentType: mimeType),
            );

        final publicUrl =
            supabase.storage.from('chat_attachment').getPublicUrl(storagePath);

        uploadedAttachments.add({
          'name': fileName,
          'path': storagePath,
          'preview': publicUrl,
          'size': await file.length(),
          'type': mimeType,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    }

    final messageData = {
      'conversation_id': conversationId,
      'sender_id': authorId,
      'body': text ?? '',
      'parent_id': replyTo,
      'content_type': uploadedAttachments.isNotEmpty ? 'media' : 'text',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    final insertedMessage = await supabase
        .from('messages')
        .insert(messageData)
        .select('id')
        .single();

    final messageId = insertedMessage['id'];

    if (uploadedAttachments.isNotEmpty) {
      final attachmentsToInsert = uploadedAttachments.map((att) {
        att['message_id'] = messageId;
        return att;
      }).toList();

      await supabase.from('attachments').insert(attachmentsToInsert);
    }
  }

  @override
  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    // Atomic RPC call prevents race conditions
    await supabase.rpc('toggle_chat_reaction', params: {
      'p_message_id': messageId,
      'p_user_id': userId,
      'p_emoji': emoji,
    });
  }

  @override
  Future<void> markConversationAsRead(
      String conversationId, String userId) async {
    await supabase
        .from('conversation_participants')
        .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('conversation_id', conversationId)
        .eq('participant_id', userId);
  }
}
