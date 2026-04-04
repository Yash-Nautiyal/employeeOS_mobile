part of 'job_application_bloc.dart';

sealed class JobApplicationState extends Equatable {
  const JobApplicationState();

  @override
  List<Object?> get props => [];
}

sealed class JobApplicationListenState extends JobApplicationState {
  const JobApplicationListenState();
}

final class JobApplicationInitial extends JobApplicationState {}

final class JobApplicationLoading extends JobApplicationState {}

final class JobApplicationFetchError extends JobApplicationState {
  final String message;

  const JobApplicationFetchError(this.message);

  @override
  List<Object?> get props => [message];
}

final class JobApplicationsLoaded extends JobApplicationState {
  final List<JobApplication> applications;
  final JobApplicationsListQuery query;
  final int totalCount;
  final bool isLoadingPage;

  const JobApplicationsLoaded({
    required this.applications,
    required this.query,
    required this.totalCount,
    this.isLoadingPage = false,
  });

  int get totalPages => query.pageSize <= 0
      ? 0
      : (totalCount + query.pageSize - 1) ~/ query.pageSize;

  JobApplicationsLoaded copyWith({
    List<JobApplication>? applications,
    JobApplicationsListQuery? query,
    int? totalCount,
    bool? isLoadingPage,
  }) {
    return JobApplicationsLoaded(
      applications: applications ?? this.applications,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }

  @override
  List<Object?> get props => [applications, query, totalCount, isLoadingPage];
}

/// Toast-only: emit then immediately restore [JobApplicationsLoaded] from the bloc.
final class JobApplicationError extends JobApplicationListenState {
  final String message;

  const JobApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
