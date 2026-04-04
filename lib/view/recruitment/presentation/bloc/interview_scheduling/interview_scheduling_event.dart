part of 'interview_scheduling_bloc.dart';

abstract class InterviewSchedulingEvent extends Equatable {
  const InterviewSchedulingEvent();

  @override
  List<Object?> get props => [];
}

class InterviewSchedulingStarted extends InterviewSchedulingEvent {}

class InterviewSearchChanged extends InterviewSchedulingEvent {
  final String query;

  const InterviewSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class InterviewFiltersApplied extends InterviewSchedulingEvent {
  final String job;
  final String interviewer;
  final String status;
  final DateTimeRange? range;

  const InterviewFiltersApplied({
    required this.job,
    required this.interviewer,
    required this.status,
    required this.range,
  });

  @override
  List<Object?> get props => [job, interviewer, status, range];
}

class InterviewFiltersReset extends InterviewSchedulingEvent {}

class InterviewTabChanged extends InterviewSchedulingEvent {
  final InterviewCandidateTab tab;

  const InterviewTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class InterviewRoundChanged extends InterviewSchedulingEvent {
  final InterviewRound round;

  const InterviewRoundChanged(this.round);

  @override
  List<Object?> get props => [round];
}

class InterviewSelectionChanged extends InterviewSchedulingEvent {
  final Set<String> selectedIds;

  const InterviewSelectionChanged(this.selectedIds);

  @override
  List<Object?> get props => [selectedIds];
}

class InterviewScheduleSubmitted extends InterviewSchedulingEvent {
  final Set<String> candidateIds;
  final InterviewScheduleDetails details;

  const InterviewScheduleSubmitted(this.candidateIds, this.details);

  @override
  List<Object?> get props => [candidateIds, details];
}

class InterviewSelectSubmitted extends InterviewSchedulingEvent {
  final Set<String> candidateIds;

  const InterviewSelectSubmitted(this.candidateIds);

  @override
  List<Object?> get props => [candidateIds];
}

class InterviewRejectSubmitted extends InterviewSchedulingEvent {
  final Set<String> candidateIds;

  const InterviewRejectSubmitted(this.candidateIds);

  @override
  List<Object?> get props => [candidateIds];
}

class InterviewOnboardSubmitted extends InterviewSchedulingEvent {
  final Set<String> candidateIds;

  const InterviewOnboardSubmitted(this.candidateIds);

  @override
  List<Object?> get props => [candidateIds];
}

class InterviewFlushSubmitted extends InterviewSchedulingEvent {
  final Set<String> candidateIds;

  const InterviewFlushSubmitted(this.candidateIds);

  @override
  List<Object?> get props => [candidateIds];
}
