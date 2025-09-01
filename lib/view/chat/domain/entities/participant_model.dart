enum ParticipantStatus { online, offline, away, busy }

class ParticipantModel {
  final String id;
  final String name;
  final String avatarUrl;
  final ParticipantStatus status;

  ParticipantModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
  });
}
