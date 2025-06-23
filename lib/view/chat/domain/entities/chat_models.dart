enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  custom,
  system,
  unsupported,
}

/// Base entity for all chat messages.
abstract class ChatMessage {
  final String id;
  final String authorId;
  final DateTime createdAt;
  final MessageType type;
  final String? replyTo;
  final Map<String, String> reactions;

  ChatMessage({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.type,
    Map<String, String>? reactions,
    this.replyTo,
  }) : reactions = reactions ?? <String, String>{};

  Map<String, dynamic> toJson();
}

/// A user-sent text message.
class TextMessage extends ChatMessage {
  final String text;

  TextMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    super.reactions,
    super.replyTo,
    required this.text,
  }) : super(
          type: MessageType.text,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'type': type.toString(),
        'replyTo': replyTo,
        'text': text,
        'reactions': reactions
      };

  factory TextMessage.fromJson(Map<String, dynamic> json) => TextMessage(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        replyTo: json['replyTo'] as String?,
        text: json['text'] as String,
        reactions: (json['reactions'] as Map<String, dynamic>?)
            ?.map((key, value) => MapEntry(key, value as String)),
      );
}

/// An image message.
class ImageMessage extends ChatMessage {
  final String url;
  final String name;
  final int size;

  ImageMessage(
      {required super.id,
      required super.authorId,
      required super.createdAt,
      required this.url,
      required this.name,
      required this.size,
      super.replyTo,
      super.reactions})
      : super(
          type: MessageType.image,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'type': type.toString(),
        'replyTo': replyTo,
        'url': url,
        'name': name,
        'size': size,
        'reactions': reactions,
      };

  factory ImageMessage.fromJson(Map<String, dynamic> json) => ImageMessage(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        replyTo: json['replyTo'] as String?,
        url: json['url'] as String,
        name: json['name'] as String,
        size: json['size'] as int,
        reactions: (json['reactions'] as Map<String, dynamic>?)
            ?.map((key, value) => MapEntry(key, value as String)),
      );
}

/// A generic file/document message.
class FileMessage extends ChatMessage {
  final String url;
  final String name;
  final int size;
  final String fileType;

  FileMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    required this.url,
    required this.name,
    required this.size,
    required this.fileType,
    super.replyTo,
    super.reactions,
  }) : super(
          type: MessageType.file,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'type': type.toString(),
        'replyTo': replyTo,
        'url': url,
        'name': name,
        'size': size,
        'reactions': reactions,
      };

  factory FileMessage.fromJson(Map<String, dynamic> json) => FileMessage(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        replyTo: json['replyTo'] as String?,
        url: json['url'] as String,
        name: json['name'] as String,
        fileType: json['fileType'] as String,
        size: json['size'] as int,
        reactions: (json['reactions'] as Map<String, dynamic>?)
            ?.map((key, value) => MapEntry(key, value as String)),
      );
}

/// A system-level message (e.g. "User joined").
class SystemMessage extends ChatMessage {
  final String text;

  SystemMessage({
    required super.id,
    required super.createdAt,
    required this.text,
  }) : super(
          authorId: 'system',
          type: MessageType.system,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'type': type.toString(),
        'text': text,
      };

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        text: json['text'] as String,
      );
}

/// A catch-all for unsupported message types.
class UnsupportedMessage extends ChatMessage {
  UnsupportedMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
  }) : super(
          type: MessageType.unsupported,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'type': type.toString(),
      };

  factory UnsupportedMessage.fromJson(Map<String, dynamic> json) =>
      UnsupportedMessage(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

List<ChatMessage> getMockChatMessages({required String currentUserId}) {
  final now = DateTime.now();
  int counter = 0;
  String rnd() => (++counter).toString();

  final messages = [
    TextMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 1, minutes: 2)),
      text: 'Replying to image message from yesterday',
      replyTo: '6',
    ),
    TextMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 1, minutes: 1)),
      text: 'Replying to file message from yesterday',
      replyTo: '8',
      reactions: {
        'user-123': '😂',
        'user_2': '😂',
        'user_3': '❤️',
        'user_4': '👍',
      },
    ),
    TextMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 2, minutes: 5)),
      text: 'Hello, this is a text message from two days ago.',
    ),
    TextMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 2, minutes: 5)),
      text:
          'Hello, this is a long text message from two days ago. Hello, this is a long text message from two days ago.',
    ),
    TextMessage(
        id: rnd(),
        authorId: currentUserId,
        createdAt: now.subtract(const Duration(days: 3, minutes: 8)),
        text: 'Replying from three days ago',
        replyTo: '3'),
    TextMessage(
      id: rnd(),
      authorId: 'user_2',
      createdAt: now.subtract(const Duration(days: 3, minutes: 4)),
      replyTo: '1',
      text: 'Replying to your text message from three days ago.',
    ),
    ImageMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 1, minutes: 3)),
      url:
          'https://plus.unsplash.com/premium_photo-1683865776032-07bf70b0add1?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'yesterday_placeholder.png',
      size: 1024,
    ),
    ImageMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 1, minutes: 3)),
      url:
          'https://images.unsplash.com/photo-1745294279347-e1bcbcb30f8c?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'wave.png',
      size: 1024,
    ),
    ImageMessage(
      id: rnd(),
      authorId: currentUserId,
      createdAt: now.subtract(const Duration(days: 1, minutes: 3)),
      url:
          'https://images.unsplash.com/photo-1517404215738-15263e9f9178?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'pen.png',
      size: 1024,
    ),
    
    FileMessage(
      id: rnd(),
      authorId: 'user_2',
      createdAt: now.subtract(const Duration(days: 2, minutes: 2)),
      url:
          'https://prhsilyjzxbkufchywxt.supabase.co/storage/v1/object/public/file_attachments/907c9198-c254-49e3-b794-0d76c3e4c101/AWS%20Script%20NW.pdf',
      name: 'document_from_two_days_ago.pdf',
      size: 204800,
      fileType: 'application/pdf',
    ),
    ImageMessage(
      id: rnd(),
      authorId: 'user_2',
      createdAt: now.subtract(const Duration(days: 2, minutes: 3)),
      url:
          'https://plus.unsplash.com/premium_photo-1676487748067-4da1e9afa701?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'mountains.png',
      size: 1024,
    ),
    ImageMessage(
      id: rnd(),
      authorId: 'user_2',
      createdAt: now.subtract(const Duration(days: 2, minutes: 3)),
      url:
          'https://images.pexels.com/photos/31636919/pexels-photo-31636919/free-photo-of-coastal-breakwater-against-ocean-waves.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      name: 'leaf.png',
      size: 22200,
    ),
  ];

  messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return messages;
}

//-----------------------------------------------------------EXTRA MESSAGES MODELS----------------------------------------------------------- 

/// An audio message.
// class AudioMessage extends ChatMessage {
//   final String url;
//   final int size;
//   final Duration duration;

//   AudioMessage({
//     required String id,
//     required String authorId,
//     required DateTime createdAt,
//     String? replyTo,
//     required this.url,
//     required this.size,
//     required this.duration,
//   }) : super(
//           id: id,
//           authorId: authorId,
//           createdAt: createdAt,
//           type: MessageType.audio,
//           replyTo: replyTo,
//         );

//   @override
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'authorId': authorId,
//         'createdAt': createdAt.toIso8601String(),
//         'type': type.toString(),
//         'replyTo': replyTo,
//         'url': url,
//         'size': size,
//         'duration': duration.inMilliseconds,
//       };

//   factory AudioMessage.fromJson(Map<String, dynamic> json) => AudioMessage(
//         id: json['id'] as String,
//         authorId: json['authorId'] as String,
//         createdAt: DateTime.parse(json['createdAt'] as String),
//         replyTo: json['replyTo'] as String?,
//         url: json['url'] as String,
//         size: json['size'] as int,
//         duration: Duration(milliseconds: json['duration'] as int),
//       );
// }

/// A video message.
// class VideoMessage extends ChatMessage {
//   final String url;
//   final String name;
//   final int size;
//   final double width;
//   final double height;

//   VideoMessage({
//     required String id,
//     required String authorId,
//     required DateTime createdAt,
//     String? replyTo,
//     required this.url,
//     required this.name,
//     required this.size,
//     required this.width,
//     required this.height,
//   }) : super(
//           id: id,
//           authorId: authorId,
//           createdAt: createdAt,
//           type: MessageType.video,
//           replyTo: replyTo,
//         );

//   @override
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'authorId': authorId,
//         'createdAt': createdAt.toIso8601String(),
//         'type': type.toString(),
//         'replyTo': replyTo,
//         'url': url,
//         'name': name,
//         'size': size,
//         'width': width,
//         'height': height,
//       };

//   factory VideoMessage.fromJson(Map<String, dynamic> json) => VideoMessage(
//         id: json['id'] as String,
//         authorId: json['authorId'] as String,
//         createdAt: DateTime.parse(json['createdAt'] as String),
//         replyTo: json['replyTo'] as String?,
//         url: json['url'] as String,
//         name: json['name'] as String,
//         size: json['size'] as int,
//         width: (json['width'] as num).toDouble(),
//         height: (json['height'] as num).toDouble(),
//       );
// }