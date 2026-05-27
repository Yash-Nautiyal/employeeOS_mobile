import '../../domain/entities/reaction.dart';

class ReactionModel extends Reaction {
  ReactionModel({
    required super.userId,
    required super.emoji,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      userId: json['user_id']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> toJSON(Reaction r) => {
        'user_id': r.userId,
        'emoji': r.emoji,
      };
}