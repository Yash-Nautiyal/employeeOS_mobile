part of 'job_application_bloc.dart';

sealed class JobApplicationEvent extends Equatable {
  const JobApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// Full filter + sort + page (use page `1` when filters/search/sort change).
final class JobApplicationsListFetchRequested extends JobApplicationEvent {
  final JobApplicationsListQuery query;

  const JobApplicationsListFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

final class JobApplicationsPageSelected extends JobApplicationEvent {
  final int page;

  const JobApplicationsPageSelected(this.page);

  @override
  List<Object?> get props => [page];
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
