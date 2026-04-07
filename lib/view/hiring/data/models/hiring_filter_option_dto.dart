import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';

class JobOptionDto {
  final String id;
  final String title;

  const JobOptionDto({
    required this.id,
    required this.title,
  });

  factory JobOptionDto.fromJson(Map<String, dynamic> json) {
    return JobOptionDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  JobOption toEntity() => JobOption(id: id, title: title);
}

class HrOptionDto {
  final String id;
  final String fullName;
  final String email;

  const HrOptionDto({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory HrOptionDto.fromJson(Map<String, dynamic> json) {
    return HrOptionDto(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  HrOption toEntity() => HrOption(id: id, fullName: fullName, email: email);
}
