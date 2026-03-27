import 'package:equatable/equatable.dart';

/// A single application to a job posting (mock only for now).
class JobApplication extends Equatable {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.appliedOn,
    required this.resumeUrl,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String fullName;
  final String email;
  final String phone;
  final String status; // e.g. 'Applied', 'Shortlisted', 'Rejected'
  final DateTime appliedOn;
  final String resumeUrl; // mock URL to resume file

  @override
  List<Object?> get props => [
        id,
        jobId,
        jobTitle,
        fullName,
        email,
        phone,
        status,
        appliedOn,
        resumeUrl,
      ];
}
