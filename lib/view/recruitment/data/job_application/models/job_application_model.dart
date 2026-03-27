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
      status: json['status'] as String? ?? 'Applied',
      appliedOn: json['applied_on'] != null
          ? DateTime.tryParse(json['applied_on'] as String) ?? DateTime.now()
          : DateTime.now(),
      resumeUrl: json['resume_url'] as String? ?? '',
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
