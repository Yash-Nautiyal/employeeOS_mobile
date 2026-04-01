import 'package:equatable/equatable.dart';

/// A single application to a job posting (`applications` table).
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

  /// `applications.status` (e.g. `pending`, `shortlisted`, `rejected` — see `application_db_values.dart`).
  final String status;
  final DateTime appliedOn;
  final String resumeUrl;

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
