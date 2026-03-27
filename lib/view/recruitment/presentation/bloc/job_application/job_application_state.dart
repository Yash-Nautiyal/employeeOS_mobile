part of 'job_application_bloc.dart';

sealed class JobApplicationState extends Equatable {
  const JobApplicationState();

  @override
  List<Object?> get props => [];
}

final class JobApplicationInitial extends JobApplicationState {}

final class JobApplicationLoading extends JobApplicationState {}

final class JobApplicationsLoaded extends JobApplicationState {
  final List<JobApplication> applications;
  final String? filterJobId;

  const JobApplicationsLoaded({
    required this.applications,
    this.filterJobId,
  });

  @override
  List<Object?> get props => [applications, filterJobId];
}

final class JobApplicationError extends JobApplicationState {
  final String message;

  const JobApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
