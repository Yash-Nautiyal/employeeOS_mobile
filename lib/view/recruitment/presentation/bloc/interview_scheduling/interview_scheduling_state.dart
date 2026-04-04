part of 'interview_scheduling_bloc.dart';

sealed class InterviewSchedulingState extends Equatable {
  const InterviewSchedulingState();

  @override
  List<Object?> get props => [];
}

sealed class InterviewSchedulingListenState extends InterviewSchedulingState {
  const InterviewSchedulingListenState();
}

final class InterviewSchedulingLoading extends InterviewSchedulingState {
  const InterviewSchedulingLoading();
}

final class InterviewSchedulingFetchError extends InterviewSchedulingState {
  final String message;

  const InterviewSchedulingFetchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Toast-only: emit then immediately restore [InterviewSchedulingReady].
final class InterviewSchedulingError extends InterviewSchedulingListenState {
  final String message;

  const InterviewSchedulingError(this.message);

  @override
  List<Object?> get props => [message];
}

final class InterviewSchedulingReady extends InterviewSchedulingState {
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

  const InterviewSchedulingReady({
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
  });

  InterviewSchedulingReady copyWith({
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
  }) {
    return InterviewSchedulingReady(
      candidates: candidates ?? this.candidates,
      filteredCandidates: filteredCandidates ?? this.filteredCandidates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedInterviewer: selectedInterviewer ?? this.selectedInterviewer,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDateRange: updateDateRange
          ? selectedDateRange
          : (selectedDateRange ?? this.selectedDateRange),
      activeTab: activeTab ?? this.activeTab,
      activeRound: activeRound ?? this.activeRound,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  /// Filter value is still [selectedJob] / [kAllJobs]; labels show `id — title` for clarity.
  List<InterviewJobFilterOption> get jobFilterOptions {
    final idToLabel = <String, String>{};
    for (final c in candidates) {
      final id = c.jobId.trim();
      if (id.isEmpty) continue;
      idToLabel.putIfAbsent(id, () {
        final t = c.jobTitle.trim();
        if (t.isEmpty) return id;
        return '$id — $t';
      });
    }
    final sorted = idToLabel.entries.toList()
      ..sort(
        (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
      );
    return [
      const InterviewJobFilterOption(value: kAllJobs, label: kAllJobs),
      ...sorted.map(
        (e) => InterviewJobFilterOption(value: e.key, label: e.value),
      ),
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
      ];
}
