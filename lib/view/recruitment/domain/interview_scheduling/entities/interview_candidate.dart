import 'package:equatable/equatable.dart';

class InterviewCandidate extends Equatable {
  final String id;
  final String name;
  final String jobTitle;
  final DateTime applicationDate;
  final DateTime interviewDate;
  final String jobId;
  final String interviewer;
  final String status;
  final String roundStageId;

  const InterviewCandidate({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.applicationDate,
    required this.interviewDate,
    required this.jobId,
    required this.interviewer,
    required this.status,
    required this.roundStageId,
  });

  bool get isScheduled => status.trim().toLowerCase() == 'scheduled';

  @override
  List<Object?> get props => [
        id,
        name,
        jobTitle,
        applicationDate,
        interviewDate,
        jobId,
        interviewer,
        status,
        roundStageId,
      ];
}
