import 'package:equatable/equatable.dart';

class JobApplicationSummary extends Equatable {
  const JobApplicationSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.appliedOn,
    required this.resumeUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String status;
  final DateTime appliedOn;
  final String resumeUrl;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        status,
        appliedOn,
        resumeUrl,
      ];
}
