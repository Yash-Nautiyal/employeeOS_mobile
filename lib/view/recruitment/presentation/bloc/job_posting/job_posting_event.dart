part of 'job_posting_bloc.dart';

sealed class JobPostingEvent extends Equatable {
  const JobPostingEvent();

  @override
  List<Object?> get props => [];
}

/// Initial / pull-to-refresh load (shows loading when list was empty).
class LoadJobPostingsEvent extends JobPostingEvent {
  const LoadJobPostingsEvent();
}

/// Reload jobs after mutations without blocking the list with a full-screen loader.
class RefreshJobPostingsEvent extends JobPostingEvent {
  const RefreshJobPostingsEvent();
}

class SetJobActiveEvent extends JobPostingEvent {
  final String jobId;
  final bool isActive;

  const SetJobActiveEvent({required this.jobId, required this.isActive});

  @override
  List<Object?> get props => [jobId, isActive];
}

class CloseJobEvent extends JobPostingEvent {
  final String jobId;

  const CloseJobEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class DeleteJobEvent extends JobPostingEvent {
  final String jobId;

  const DeleteJobEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ClearTransientErrorEvent extends JobPostingEvent {
  const ClearTransientErrorEvent();
}
