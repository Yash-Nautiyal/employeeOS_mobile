part of 'job_posting_detail_cubit.dart';

class JobPostingDetailState extends Equatable {
  const JobPostingDetailState({
    this.isJobLoading = false,
    this.job,
    this.jobError,
    this.isApplicationsLoading = false,
    this.applications = const [],
    this.applicationsError,
    this.sortAsc = false,
    this.applicationsPage = 1,
    this.applicationsTotalPages = 1,
    this.selectedApplicationIds = const <String>{},
  });

  final bool isJobLoading;
  final JobPosting? job;
  final String? jobError;

  final bool isApplicationsLoading;
  final List<JobApplicationSummary> applications;
  final String? applicationsError;
  final bool sortAsc;
  final int applicationsPage;
  final int applicationsTotalPages;
  final Set<String> selectedApplicationIds;

  bool get hasSelection => selectedApplicationIds.isNotEmpty;

  JobPostingDetailState copyWith({
    bool? isJobLoading,
    JobPosting? job,
    String? jobError,
    bool clearJobError = false,
    bool? isApplicationsLoading,
    List<JobApplicationSummary>? applications,
    String? applicationsError,
    bool clearApplicationsError = false,
    bool? sortAsc,
    int? applicationsPage,
    int? applicationsTotalPages,
    Set<String>? selectedApplicationIds,
  }) {
    return JobPostingDetailState(
      isJobLoading: isJobLoading ?? this.isJobLoading,
      job: job ?? this.job,
      jobError: clearJobError ? null : (jobError ?? this.jobError),
      isApplicationsLoading:
          isApplicationsLoading ?? this.isApplicationsLoading,
      applications: applications ?? this.applications,
      applicationsError: clearApplicationsError
          ? null
          : (applicationsError ?? this.applicationsError),
      sortAsc: sortAsc ?? this.sortAsc,
      applicationsPage: applicationsPage ?? this.applicationsPage,
      applicationsTotalPages:
          applicationsTotalPages ?? this.applicationsTotalPages,
      selectedApplicationIds:
          selectedApplicationIds ?? this.selectedApplicationIds,
    );
  }

  @override
  List<Object?> get props => [
        isJobLoading,
        job,
        jobError,
        isApplicationsLoading,
        applications,
        applicationsError,
        sortAsc,
        applicationsPage,
        applicationsTotalPages,
        selectedApplicationIds,
      ];
}
