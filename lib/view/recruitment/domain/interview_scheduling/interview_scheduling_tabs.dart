import 'package:equatable/equatable.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_posting.dart';

abstract class InterviewSchedulingRoundIds {
  InterviewSchedulingRoundIds._();

  static const selected = '__sched_selected__';
  static const rejected = '__sched_rejected__';
}

class InterviewSchedulingRoundTab extends Equatable {
  const InterviewSchedulingRoundTab({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

List<InterviewSchedulingRoundTab> buildInterviewSchedulingTabs(JobPosting job) {
  final pipeline = job.pipeline ?? [];

  final tabs = pipeline
      .map(
        (s) => InterviewSchedulingRoundTab(id: s.id, label: s.name),
      )
      .toList();

  tabs.addAll(const [
    InterviewSchedulingRoundTab(
      id: InterviewSchedulingRoundIds.selected,
      label: 'Selected',
    ),
    InterviewSchedulingRoundTab(
      id: InterviewSchedulingRoundIds.rejected,
      label: 'Rejected',
    ),
  ]);

  return tabs;
}

bool candidateMatchesSchedulingRound(
  String activeRoundId,
  String candidateRoundStageId,
  String status,
) {
  final s = status.trim().toLowerCase();
  if (activeRoundId == InterviewSchedulingRoundIds.selected) {
    return s == 'selected' || s == 'hired' || s == 'offer';
  }
  if (activeRoundId == InterviewSchedulingRoundIds.rejected) {
    return s == 'rejected';
  }
  return candidateRoundStageId == activeRoundId;
}
