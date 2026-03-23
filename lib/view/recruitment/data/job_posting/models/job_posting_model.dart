import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_posting.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/entities/pipeline_stage.dart';

class JobPostingModel extends JobPosting {
  const JobPostingModel({
    required super.id,
    required super.title,
    required super.department,
    super.description,
    super.location,
    super.positions,
    super.lastDateToApply,
    required super.joiningType,
    super.isInternship,
    super.ctcRange,
    required super.postedByName,
    required super.postedByEmail,
    super.createdAt,
    super.pipeline,
    super.isActive,
  });

  factory JobPostingModel.fromJson(Map<String, dynamic> json) {
    return JobPostingModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      department: json['department'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      positions: (json['positions'] as num?)?.toInt() ?? 1,
      lastDateToApply: json['last_date_to_apply'] != null
          ? DateTime.tryParse(json['last_date_to_apply'] as String)
          : null,
      joiningType: json['joining_type'] as String? ?? 'Immediate',
      isInternship: json['is_internship'] as bool? ?? false,
      ctcRange: json['ctc_range'] as String?,
      postedByName: json['posted_by_name'] as String? ?? '',
      postedByEmail: json['posted_by_email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      pipeline: (json['pipeline'] as List<dynamic>?)?.map((e) {
        final map = e as Map<String, dynamic>;
        final typeName = map['type'] as String? ?? 'statusOnly';
        final type = PipelineStageType.values.firstWhere(
          (t) => t.name == typeName,
          orElse: () => PipelineStageType.statusOnly,
        );
        return PipelineStage(
          id: map['id'] as String? ?? '',
          name: map['name'] as String? ?? '',
          type: type,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'description': description,
      'location': location,
      'positions': positions,
      'last_date_to_apply': lastDateToApply?.toIso8601String(),
      'joining_type': joiningType,
      'is_internship': isInternship,
      'ctc_range': ctcRange,
      'posted_by_name': postedByName,
      'posted_by_email': postedByEmail,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
      'pipeline': pipeline
          ?.map((s) => {
                'id': s.id,
                'name': s.name,
                'type': s.type.name,
              })
          .toList(),
    };
  }

  JobPostingModel copyWith({
    String? id,
    String? title,
    String? department,
    String? description,
    String? location,
    int? positions,
    DateTime? lastDateToApply,
    String? joiningType,
    bool? isInternship,
    String? ctcRange,
    String? postedByName,
    String? postedByEmail,
    DateTime? createdAt,
    List<PipelineStage>? pipeline,
    bool? isActive,
  }) {
    return JobPostingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      department: department ?? this.department,
      description: description ?? this.description,
      location: location ?? this.location,
      positions: positions ?? this.positions,
      lastDateToApply: lastDateToApply ?? this.lastDateToApply,
      joiningType: joiningType ?? this.joiningType,
      isInternship: isInternship ?? this.isInternship,
      ctcRange: ctcRange ?? this.ctcRange,
      postedByName: postedByName ?? this.postedByName,
      postedByEmail: postedByEmail ?? this.postedByEmail,
      createdAt: createdAt ?? this.createdAt,
      pipeline: pipeline ?? this.pipeline,
      isActive: isActive ?? this.isActive,
    );
  }
}
