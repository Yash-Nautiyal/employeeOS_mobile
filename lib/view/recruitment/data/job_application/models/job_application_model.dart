import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';

class JobApplicationModel extends JobApplication {
  const JobApplicationModel({
    required super.id,
    required super.jobId,
    required super.jobTitle,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.status,
    required super.appliedOn,
    required super.resumeUrl,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      appliedOn: json['applied_on'] != null
          ? DateTime.tryParse(json['applied_on'] as String) ?? DateTime.now()
          : DateTime.now(),
      resumeUrl: json['resume_url'] as String? ?? '',
    );
  }

  /// Row from `applications` with optional nested `jobs(job_id, title)` from PostgREST.
  factory JobApplicationModel.fromDbJson(Map<String, dynamic> row) {
    var businessJobId = '';
    var jobTitle = '';
    final jobs = row['jobs'];
    if (jobs is Map) {
      final m = Map<String, dynamic>.from(jobs);
      businessJobId = m['job_id']?.toString() ?? '';
      jobTitle = m['title']?.toString() ?? '';
    }

    final appliedRaw = row['created_at']?.toString();

    return JobApplicationModel(
      id: row['id']?.toString() ?? '',
      jobId: businessJobId,
      jobTitle: jobTitle,
      fullName: row['applicant_name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      phone: row['phone_number']?.toString() ?? '',
      status: row['status']?.toString() ?? 'pending',
      appliedOn: DateTime.tryParse(appliedRaw ?? '') ?? DateTime.now(),
      resumeUrl: row['resume_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'status': status,
      'applied_on': appliedOn.toIso8601String(),
      'resume_url': resumeUrl,
    };
  }

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? fullName,
    String? email,
    String? phone,
    String? status,
    DateTime? appliedOn,
    String? resumeUrl,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      appliedOn: appliedOn ?? this.appliedOn,
      resumeUrl: resumeUrl ?? this.resumeUrl,
    );
  }
}
