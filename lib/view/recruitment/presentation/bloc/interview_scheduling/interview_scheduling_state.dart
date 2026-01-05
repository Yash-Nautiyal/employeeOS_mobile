part of 'interview_scheduling_bloc.dart';

class InterviewSchedulingState extends Equatable {
  final bool isLoading;
  final List<InterviewCandidate> candidates;
  final List<InterviewCandidate> filteredCandidates;
  final String searchQuery;
  final String selectedJob;
  final String selectedInterviewer;
  final String selectedStatus;
  final DateTimeRange? selectedDateRange;
  final InterviewCandidateTab activeTab;
  final InterviewRound activeRound;
  final Set<String> selectedIds;
  final String? errorMessage;

  const InterviewSchedulingState({
    required this.isLoading,
    required this.candidates,
    required this.filteredCandidates,
    required this.searchQuery,
    required this.selectedJob,
    required this.selectedInterviewer,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.activeTab,
    required this.activeRound,
    required this.selectedIds,
    required this.errorMessage,
  });

  factory InterviewSchedulingState.initial() {
    return const InterviewSchedulingState(
      isLoading: false,
      candidates: [],
      filteredCandidates: [],
      searchQuery: '',
      selectedJob: kAllJobs,
      selectedInterviewer: kAllInterviewers,
      selectedStatus: kAllStatus,
      selectedDateRange: null,
      activeTab: InterviewCandidateTab.eligible,
      activeRound: InterviewRound.technical,
      selectedIds: {},
      errorMessage: null,
    );
  }

  InterviewSchedulingState copyWith({
    bool? isLoading,
    List<InterviewCandidate>? candidates,
    List<InterviewCandidate>? filteredCandidates,
    String? searchQuery,
    String? selectedJob,
    String? selectedInterviewer,
    String? selectedStatus,
    DateTimeRange? selectedDateRange,
    bool updateDateRange = false,
    InterviewCandidateTab? activeTab,
    InterviewRound? activeRound,
    Set<String>? selectedIds,
    String? errorMessage,
  }) {
    return InterviewSchedulingState(
      isLoading: isLoading ?? this.isLoading,
      candidates: candidates ?? this.candidates,
      filteredCandidates: filteredCandidates ?? this.filteredCandidates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedInterviewer: selectedInterviewer ?? this.selectedInterviewer,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDateRange:
          updateDateRange ? selectedDateRange : (selectedDateRange ?? this.selectedDateRange),
      activeTab: activeTab ?? this.activeTab,
      activeRound: activeRound ?? this.activeRound,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage,
    );
  }

  List<String> get jobOptions => [
        kAllJobs,
        ...candidates.map((c) => c.jobId).where((id) => id.isNotEmpty).toSet()
      ];

  List<String> get interviewerOptions => [
        kAllInterviewers,
        ...candidates
            .map((c) => c.interviewer)
            .where((id) => id.isNotEmpty)
            .toSet()
      ];

  List<String> get statusOptions => [
        kAllStatus,
        ...candidates
            .map((c) => c.status)
            .where((id) => id.isNotEmpty)
            .toSet()
      ];

  @override
  List<Object?> get props => [
        isLoading,
        candidates,
        filteredCandidates,
        searchQuery,
        selectedJob,
        selectedInterviewer,
        selectedStatus,
        selectedDateRange,
        activeTab,
        activeRound,
        selectedIds,
        errorMessage,
      ];
}

