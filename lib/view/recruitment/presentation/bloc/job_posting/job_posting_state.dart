part of 'job_posting_bloc.dart';

sealed class JobPostingState extends Equatable {
  const JobPostingState();

  @override
  List<Object?> get props => [];
}

final class JobPostingInitial extends JobPostingState {}

final class JobPostingLoading extends JobPostingState {}

final class JobPostingLoaded extends JobPostingState {
  final List<JobPosting> jobs;
  final Map<String, int> applicationCounts;
  final String? transientError;

  const JobPostingLoaded({
    required this.jobs,
    required this.applicationCounts,
    this.transientError,
  });

  JobPostingLoaded copyWith({
    List<JobPosting>? jobs,
    Map<String, int>? applicationCounts,
    String? transientError,
    bool clearTransientError = false,
  }) {
    return JobPostingLoaded(
      jobs: jobs ?? this.jobs,
      applicationCounts: applicationCounts ?? this.applicationCounts,
      transientError:
          clearTransientError ? null : (transientError ?? this.transientError),
    );
  }

  JobPostingCardViewModel? snapshotFor(String jobId) {
    JobPosting? found;
    for (final j in jobs) {
      if (j.id == jobId) {
        found = j;
        break;
      }
    }
    if (found == null) return null;
    return JobPostingCardViewModel(
      job: found,
      applicationCount: applicationCounts[jobId] ?? 0,
    );
  }

  @override
  List<Object?> get props => [jobs, applicationCounts, transientError];
}

/// Shown only when the first load fails (no cached list to show).
final class JobPostingLoadError extends JobPostingState {
  final String message;

  const JobPostingLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Immutable slice for [BlocSelector] so only the card for [job] rebuilds when its data changes.
final class JobPostingCardViewModel extends Equatable {
  final JobPosting job;
  final int applicationCount;

  const JobPostingCardViewModel({
    required this.job,
    required this.applicationCount,
  });

  @override
  List<Object?> get props => [job, applicationCount];
}
