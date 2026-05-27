// import 'package:employeeos/view/chat/data/test_data.dart';
// import 'package:employeeos/view/chat/domain/entities/conversation.dart';

// abstract class ChatLocalDataSource {
//   List<Conversation> getConversations();
//   Conversation? getConversationById(String id);
//   void sendMessage({
//     required String conversationId,
//     required String text,
//     required String authorId,
//   });
//   void addReaction({
//     required String conversationId,
//     required String messageId,
//     required String emoji,
//     required String userId,
//   });
// }

// class ChatLocalDataSourceImpl implements ChatLocalDataSource {
//   final List<Conversation> _conversations;

//   ChatLocalDataSourceImpl() : _conversations = List.from(testConversations);

//   @override
//   List<Conversation> getConversations() {
//     return _conversations;
//   }

//   @override
//   Conversation? getConversationById(String id) {
//     try {
//       return _conversations.firstWhere((conv) => conv.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   void sendMessage({
//     required String conversationId,
//     required String text,
//     required String authorId,
//   }) {
//     final conversation = _conversations.firstWhere(
//       (conv) => conv.id == conversationId,
//     );
    
//     // In a real implementation, you would add the message to the conversation
//     // For now, this is a placeholder
//   }

//   @override
//   void addReaction({
//     required String conversationId,
//     required String messageId,
//     required String emoji,
//     required String userId,
//   }) {
//     final conversation = _conversations.firstWhere(
//       (conv) => conv.id == conversationId,
//     );
    
//     // In a real implementation, you would add the reaction to the message
//     // For now, this is a placeholder
//   }
// }
