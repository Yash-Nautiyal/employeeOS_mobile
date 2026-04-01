import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_posting.dart';

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
    );
  }

  factory JobPostingModel.fromDbJson(Map<String, dynamic> json) {
    final positionsRaw = json['positions'];
    final positions = positionsRaw is num
        ? positionsRaw.toInt()
        : int.tryParse(positionsRaw?.toString() ?? '') ?? 1;

    return JobPostingModel(
      id: (json['job_id'] as String?) ?? (json['id'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      department: json['department'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      positions: positions,
      lastDateToApply: _parseDate(json['last_date']),
      joiningType: json['joining_type'] as String? ?? 'Immediate',
      isInternship: json['is_internship'] as bool? ?? false,
      ctcRange: json['expected_ctc_range'] as String?,
      postedByName: json['posted_by_name'] as String? ?? '',
      postedByEmail: json['posted_by_email'] as String? ?? '',
      createdAt: _parseDate(json['created_at']),
      isActive: json['is_active'] as bool? ?? true,
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
    };
  }

  Map<String, dynamic> toDbInsertJson() {
    return {
      'title': title,
      'department': department,
      'description': description,
      'location': location,
      'is_internship': isInternship,
      'expected_ctc_range': ctcRange,
      'is_active': isActive,
      'joining_type': joiningType,
      'positions': positions.toString(),
      'last_date': _formatDate(lastDateToApply),
      'posted_by_name': postedByName,
      'posted_by_email': postedByEmail,
    };
  }

  Map<String, dynamic> toDbUpdateJson() {
    return {
      'title': title,
      'department': department,
      'description': description,
      'location': location,
      'is_internship': isInternship,
      'expected_ctc_range': ctcRange,
      'joining_type': joiningType,
      'positions': positions.toString(),
      'last_date': _formatDate(lastDateToApply),
      'posted_by_name': postedByName,
      'posted_by_email': postedByEmail,
      'is_active': isActive,
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
      isActive: isActive ?? this.isActive,
    );
  }

  factory JobPostingModel.toModel(JobPosting job) {
    if (job is JobPostingModel) return job;
    return JobPostingModel(
      id: job.id,
      title: job.title,
      department: job.department,
      description: job.description,
      location: job.location,
      positions: job.positions,
      lastDateToApply: job.lastDateToApply,
      joiningType: job.joiningType,
      isInternship: job.isInternship,
      ctcRange: job.ctcRange,
      postedByName: job.postedByName,
      postedByEmail: job.postedByEmail,
      createdAt: job.createdAt,
      isActive: job.isActive,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String().split('T').first;
  }
}
