part of 'interview_scheduling_bloc.dart';

class InterviewSchedulingState extends Equatable {
  final bool isLoading;
  final List<InterviewCandidate> candidates;
  final List<InterviewCandidate> filteredCandidates;
  final String searchQuery;
  final String jobId;
  final bool lockJobFilter;
  final List<InterviewSchedulingRoundTab> roundTabs;
  final String activeRoundId;
  final String selectedJob;
  final String selectedInterviewer;
  final String selectedStatus;
  final DateTimeRange? selectedDateRange;
  final InterviewCandidateTab activeTab;
  final Set<String> selectedIds;
  final String? errorMessage;

  const InterviewSchedulingState({
    required this.isLoading,
    required this.candidates,
    required this.filteredCandidates,
    required this.searchQuery,
    required this.jobId,
    required this.lockJobFilter,
    required this.roundTabs,
    required this.activeRoundId,
    required this.selectedJob,
    required this.selectedInterviewer,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.activeTab,
    required this.selectedIds,
    required this.errorMessage,
  });

  factory InterviewSchedulingState.initial() {
    return const InterviewSchedulingState(
      isLoading: false,
      candidates: [],
      filteredCandidates: [],
      searchQuery: '',
      jobId: '',
      lockJobFilter: false,
      roundTabs: [],
      activeRoundId: '',
      selectedJob: kAllJobs,
      selectedInterviewer: kAllInterviewers,
      selectedStatus: kAllStatus,
      selectedDateRange: null,
      activeTab: InterviewCandidateTab.eligible,
      selectedIds: {},
      errorMessage: null,
    );
  }

  InterviewSchedulingState copyWith({
    bool? isLoading,
    List<InterviewCandidate>? candidates,
    List<InterviewCandidate>? filteredCandidates,
    String? searchQuery,
    String? jobId,
    bool? lockJobFilter,
    List<InterviewSchedulingRoundTab>? roundTabs,
    String? activeRoundId,
    String? selectedJob,
    String? selectedInterviewer,
    String? selectedStatus,
    DateTimeRange? selectedDateRange,
    bool updateDateRange = false,
    InterviewCandidateTab? activeTab,
    Set<String>? selectedIds,
    String? errorMessage,
  }) {
    return InterviewSchedulingState(
      isLoading: isLoading ?? this.isLoading,
      candidates: candidates ?? this.candidates,
      filteredCandidates: filteredCandidates ?? this.filteredCandidates,
      searchQuery: searchQuery ?? this.searchQuery,
      jobId: jobId ?? this.jobId,
      lockJobFilter: lockJobFilter ?? this.lockJobFilter,
      roundTabs: roundTabs ?? this.roundTabs,
      activeRoundId: activeRoundId ?? this.activeRoundId,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedInterviewer: selectedInterviewer ?? this.selectedInterviewer,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDateRange: updateDateRange
          ? selectedDateRange
          : (selectedDateRange ?? this.selectedDateRange),
      activeTab: activeTab ?? this.activeTab,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage,
    );
  }

  List<String> get jobOptions {
    if (lockJobFilter && jobId.isNotEmpty) {
      return [jobId];
    }
    return [
      kAllJobs,
      ...candidates.map((c) => c.jobId).where((id) => id.isNotEmpty).toSet()
    ];
  }

  List<String> get interviewerOptions => [
        kAllInterviewers,
        ...candidates
            .map((c) => c.interviewer)
            .where((id) => id.isNotEmpty)
            .toSet()
      ];

  List<String> get statusOptions => [
        kAllStatus,
        ...candidates.map((c) => c.status).where((id) => id.isNotEmpty).toSet()
      ];

  @override
  List<Object?> get props => [
        isLoading,
        candidates,
        filteredCandidates,
        searchQuery,
        jobId,
        lockJobFilter,
        roundTabs,
        activeRoundId,
        selectedJob,
        selectedInterviewer,
        selectedStatus,
        selectedDateRange,
        activeTab,
        selectedIds,
        errorMessage,
      ];
}
