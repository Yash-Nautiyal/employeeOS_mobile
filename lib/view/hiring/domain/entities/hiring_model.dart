import 'dart:ui';

enum JobTitle {
  developer,
  designer,
  manager,
  analyst,
  intern,
  videoEditor,
  englishContentWriter,
  dataScientist,
  awsCloudIntern,
  socialMediaManager,
}

// Extensions for better display names
extension JobTitleExtension on JobTitle {
  String get displayName {
    switch (this) {
      case JobTitle.developer:
        return 'Developer';
      case JobTitle.designer:
        return 'Designer';
      case JobTitle.manager:
        return 'Manager';
      case JobTitle.analyst:
        return 'Analyst';
      case JobTitle.intern:
        return 'Intern';
      case JobTitle.videoEditor:
        return 'Video Editor';
      case JobTitle.englishContentWriter:
        return 'English Content Writer';
      case JobTitle.dataScientist:
        return 'Data Scientist';
      case JobTitle.awsCloudIntern:
        return 'AWS Cloud Intern';
      case JobTitle.socialMediaManager:
        return 'Social Media Manager';
    }
  }
}

// Chart data model for hiring positions
class HiringData {
  final JobTitle jobTitle;
  final int count;
  final Color color;

  HiringData({
    required this.jobTitle,
    required this.count,
    required this.color,
  });

  HiringData copyWith({
    JobTitle? jobTitle,
    int? count,
    Color? color,
  }) {
    return HiringData(
      jobTitle: jobTitle ?? this.jobTitle,
      count: count ?? this.count,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle.toString(),
      'count': count,
      'color': color.value,
    };
  }

  factory HiringData.fromJson(Map<String, dynamic> json) {
    return HiringData(
      jobTitle: JobTitle.values.firstWhere(
        (e) => e.toString() == json['jobTitle'],
      ),
      count: json['count'] as int,
      color: Color(json['color'] as int),
    );
  }
}
