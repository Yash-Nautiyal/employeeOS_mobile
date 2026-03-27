part of 'job_application_bloc.dart';

sealed class JobApplicationEvent extends Equatable {
  const JobApplicationEvent();

  @override
  List<Object?> get props => [];
}

final class JobApplicationsLoadRequested extends JobApplicationEvent {
  final String? jobId;

  const JobApplicationsLoadRequested({this.jobId});

  @override
  List<Object?> get props => [jobId];
}

final class JobApplicationShortlistRequested extends JobApplicationEvent {
  final String applicationId;

  const JobApplicationShortlistRequested(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

final class JobApplicationRejectRequested extends JobApplicationEvent {
  final String applicationId;

  const JobApplicationRejectRequested(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}
