import 'package:bloc/bloc.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/interview_scheduling_tabs.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/usecases/get_interview_candidates_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'interview_scheduling_event.dart';
part 'interview_scheduling_state.dart';

const String kAllJobs = 'All Jobs';
const String kAllInterviewers = 'All Interviewers';
const String kAllStatus = 'All';

class InterviewSchedulingBloc
    extends Bloc<InterviewSchedulingEvent, InterviewSchedulingState> {
  final GetInterviewCandidatesUseCase getInterviewCandidatesUseCase;

  InterviewSchedulingBloc({
    required this.getInterviewCandidatesUseCase,
  }) : super(InterviewSchedulingState.initial()) {
    on<InterviewSchedulingStarted>(_onStarted);
    on<InterviewSearchChanged>(_onSearchChanged);
    on<InterviewFiltersApplied>(_onFiltersApplied);
    on<InterviewFiltersReset>(_onFiltersReset);
    on<InterviewTabChanged>(_onTabChanged);
    on<InterviewRoundChanged>(_onRoundChanged);
    on<InterviewSelectionChanged>(_onSelectionChanged);
  }

  Future<void> _onStarted(
    InterviewSchedulingStarted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (event.roundTabs.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'No scheduling rounds for this job.',
          ),
        );
        return;
      }

      final candidates = await getInterviewCandidatesUseCase.call(event.jobId);

      emit(
        _applyFilters(
          state.copyWith(
            isLoading: false,
            candidates: candidates,
            jobId: event.jobId,
            lockJobFilter: event.lockJobFilter,
            roundTabs: event.roundTabs,
            activeRoundId: event.roundTabs.first.id,
            selectedJob: event.jobId,
            selectedInterviewer: kAllInterviewers,
            selectedStatus: kAllStatus,
            selectedDateRange: null,
            updateDateRange: true,
            selectedIds: const {},
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load candidates: $e',
        ),
      );
    }
  }

  void _onSearchChanged(
    InterviewSearchChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    emit(_applyFilters(state.copyWith(searchQuery: event.query)));
  }

  void _onFiltersApplied(
    InterviewFiltersApplied event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    emit(
      _applyFilters(
        state.copyWith(
          selectedJob: event.job,
          selectedInterviewer: event.interviewer,
          selectedStatus: event.status,
          selectedDateRange: event.range,
          updateDateRange: true,
        ),
      ),
    );
  }

  void _onFiltersReset(
    InterviewFiltersReset event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    final resetJob = state.lockJobFilter ? state.jobId : kAllJobs;
    emit(
      _applyFilters(
        state.copyWith(
          selectedJob: resetJob,
          selectedInterviewer: kAllInterviewers,
          selectedStatus: kAllStatus,
          selectedDateRange: null,
          updateDateRange: true,
          selectedIds: const {},
        ),
      ),
    );
  }

  void _onTabChanged(
    InterviewTabChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    emit(_applyFilters(state.copyWith(activeTab: event.tab)));
  }

  void _onRoundChanged(
    InterviewRoundChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    emit(_applyFilters(state.copyWith(activeRoundId: event.roundId)));
  }

  void _onSelectionChanged(
    InterviewSelectionChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    emit(state.copyWith(selectedIds: event.selectedIds));
  }

  InterviewSchedulingState _applyFilters(
    InterviewSchedulingState targetState,
  ) {
    final search = targetState.searchQuery.toLowerCase().trim();
    final filtered = targetState.candidates.where((candidate) {
      if (!candidateMatchesSchedulingRound(
        targetState.activeRoundId,
        candidate.roundStageId,
        candidate.status,
      )) {
        return false;
      }

      final isSearchMatch = search.isEmpty ||
          candidate.name.toLowerCase().contains(search) ||
          candidate.jobTitle.toLowerCase().contains(search);

      if (!isSearchMatch) return false;

      if (targetState.selectedJob != kAllJobs &&
          candidate.jobId != targetState.selectedJob) {
        return false;
      }
      if (targetState.selectedInterviewer != kAllInterviewers &&
          candidate.interviewer != targetState.selectedInterviewer) {
        return false;
      }
      if (targetState.selectedStatus != kAllStatus &&
          candidate.status != targetState.selectedStatus) {
        return false;
      }

      if (targetState.selectedDateRange != null) {
        final start = targetState.selectedDateRange!.start;
        final end = targetState.selectedDateRange!.end;
        if (candidate.interviewDate.isBefore(start) ||
            candidate.interviewDate.isAfter(end)) {
          return false;
        }
      }

      if (targetState.activeTab == InterviewCandidateTab.eligible &&
          candidate.isScheduled) {
        return false;
      }
      if (targetState.activeTab == InterviewCandidateTab.scheduled &&
          !candidate.isScheduled) {
        return false;
      }
      return true;
    }).toList();

    final visibleIds = filtered.map((c) => c.id).toSet();
    final selectedIds =
        targetState.selectedIds.where((id) => visibleIds.contains(id)).toSet();

    return targetState.copyWith(
      filteredCandidates: filtered,
      selectedIds: selectedIds,
      errorMessage: null,
    );
  }
}
