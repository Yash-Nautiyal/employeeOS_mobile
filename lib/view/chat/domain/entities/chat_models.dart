import 'package:employeeos/view/chat/domain/entities/reaction_model.dart';

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
  final List<ReactionModel> reactions;

  ChatMessage({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.type,
    List<ReactionModel>? reactions,
    this.replyTo,
  }) : reactions = reactions ?? <ReactionModel>[];

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
        reactions: (json['reactions'] as List<dynamic>?)
            ?.map((item) => ReactionModel.fromJson(item))
            .toList(),
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
        reactions: (json['reactions'] as List<dynamic>?)
            ?.map((item) => ReactionModel.fromJson(item))
            .toList(),
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
        reactions: (json['reactions'] as List<dynamic>?)
            ?.map((item) => ReactionModel.fromJson(item))
            .toList(),
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