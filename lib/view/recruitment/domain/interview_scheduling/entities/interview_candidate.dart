import 'package:equatable/equatable.dart';

import 'interview_enums.dart';

class InterviewCandidate extends Equatable {
  final String id;
  final String name;
  final String email;
  final String jobTitle;
  final DateTime applicationDate;
  final DateTime interviewDate;
  final String jobId;
  final String interviewer;

  /// Row status within the current pipeline step, e.g. Eligible / Scheduled / Selected.
  final String status;

  /// Which top-level round tab this candidate belongs to.
  final InterviewRound pipelineRound;

  /// When [pipelineRound] is [InterviewRound.rejected], the round they were rejected from.
  final InterviewRound? rejectedFromRound;

  const InterviewCandidate({
    required this.id,
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.applicationDate,
    required this.interviewDate,
    required this.jobId,
    required this.interviewer,
    required this.status,
    required this.pipelineRound,
    this.rejectedFromRound,
  });

  bool get isScheduled => status.trim().toLowerCase() == 'scheduled';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        jobTitle,
        applicationDate,
        interviewDate,
        jobId,
        interviewer,
        status,
        pipelineRound,
        rejectedFromRound,
      ];
}
