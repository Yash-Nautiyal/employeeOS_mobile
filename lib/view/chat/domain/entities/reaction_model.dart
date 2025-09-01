class ReactionModel {
  final String userId;
  final String emoji;

  ReactionModel({
    required this.userId,
    required this.emoji,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
    );
  }
}
