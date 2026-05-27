
import '../../domain/entities/participant.dart';

class ParticipantModel extends Participant {
  ParticipantModel({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.status,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'] ?? json;

    ParticipantStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'online':
          return ParticipantStatus.online;
        case 'away':
          return ParticipantStatus.away;
        case 'busy':
          return ParticipantStatus.busy;
        default:
          return ParticipantStatus.offline;
      }
    }

    return ParticipantModel(
      id: userInfo['id']?.toString() ?? '',
      name: userInfo['full_name']?.toString() ?? 'Unknown',
      avatarUrl: userInfo['avatar_url']?.toString() ?? '',
      status: parseStatus(userInfo['status']?.toString()),
    );
  }

  static Map<String, dynamic> toJSON(Participant participant) {
    return {
      'id': participant.id,
      'name': participant.name,
      'avatarUrl': participant.avatarUrl,
      'status': participant.status.name,
    };
  }
}