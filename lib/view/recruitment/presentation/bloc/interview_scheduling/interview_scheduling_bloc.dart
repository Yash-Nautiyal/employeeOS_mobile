import 'package:bloc/bloc.dart';
import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_batch_mutation_result.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_schedule_details.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/repositories/interview_scheduling_repository.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/usecases/get_interview_candidates_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'interview_scheduling_event.dart';
part 'interview_scheduling_state.dart';

const String kAllJobs = 'All Jobs';
const String kAllInterviewers = 'All Interviewers';
const String kAllStatus = 'All';

/// Job filter row: [value] is [kAllJobs] or [InterviewCandidate.jobId]; [label] is shown in the UI.
@immutable
class InterviewJobFilterOption {
  const InterviewJobFilterOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class InterviewSchedulingBloc
    extends Bloc<InterviewSchedulingEvent, InterviewSchedulingState> {
  final GetInterviewCandidatesUseCase getInterviewCandidatesUseCase;
  final InterviewSchedulingRepository repository;

  InterviewSchedulingBloc({
    required this.getInterviewCandidatesUseCase,
    required this.repository,
  }) : super(const InterviewSchedulingLoading()) {
    on<InterviewSchedulingStarted>(_onStarted);
    on<InterviewSearchChanged>(_onSearchChanged);
    on<InterviewFiltersApplied>(_onFiltersApplied);
    on<InterviewFiltersReset>(_onFiltersReset);
    on<InterviewTabChanged>(_onTabChanged);
    on<InterviewRoundChanged>(_onRoundChanged);
    on<InterviewSelectionChanged>(_onSelectionChanged);
    on<InterviewScheduleSubmitted>(_onScheduleSubmitted);
    on<InterviewSelectSubmitted>(_onSelectSubmitted);
    on<InterviewRejectSubmitted>(_onRejectSubmitted);
    on<InterviewOnboardSubmitted>(_onOnboardSubmitted);
    on<InterviewFlushSubmitted>(_onFlushSubmitted);
  }

  InterviewSchedulingReady? _readyOrNull(InterviewSchedulingState s) =>
      s is InterviewSchedulingReady ? s : null;

  Future<void> _onStarted(
    InterviewSchedulingStarted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    emit(const InterviewSchedulingLoading());
    try {
      final candidates = await getInterviewCandidatesUseCase.call();
      final ready = InterviewSchedulingReady(
        candidates: candidates,
        filteredCandidates: candidates,
        searchQuery: '',
        selectedJob: kAllJobs,
        selectedInterviewer: kAllInterviewers,
        selectedStatus: kAllStatus,
        selectedDateRange: null,
        activeTab: InterviewCandidateTab.eligible,
        activeRound: InterviewRound.telephone,
        selectedIds: const {},
      );
      emit(_applyFilters(ready));
    } catch (e) {
      emit(InterviewSchedulingFetchError(
        'Failed to load candidates: ${_errorMessage(e)}',
      ));
    }
  }

  Future<void> _emitAfterMutation({
    required Emitter<InterviewSchedulingState> emit,
    required InterviewSchedulingReady snapshot,
    required InterviewBatchMutationResult batch,
    required String actionPhrase,
    InterviewCandidateTab? forceActiveTab,
  }) async {
    try {
      final candidates = await getInterviewCandidatesUseCase.call();
      final tab = forceActiveTab ?? snapshot.activeTab;
      final next = _applyFilters(
        snapshot.copyWith(
          candidates: candidates,
          selectedIds: const {},
          activeTab: tab,
        ),
      );
      if (batch.hasFailures) {
        emit(InterviewSchedulingError(
          _batchMutationToast(batch, actionPhrase),
        ));
      }
      emit(next);
    } catch (e) {
      emit(InterviewSchedulingError(
        'Could not refresh candidates: ${_errorMessage(e)}',
      ));
      emit(snapshot);
    }
  }

  Future<void> _onScheduleSubmitted(
    InterviewScheduleSubmitted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    if (event.candidateIds.isEmpty) return;
    final ready = _readyOrNull(state);
    if (ready == null) return;
    if (!ready.activeRound.usesEligibleScheduledTabs) return;

    final batch = await repository.scheduleInterviews(
      event.candidateIds,
      ready.activeRound,
      event.details,
    );

    await _emitAfterMutation(
      emit: emit,
      snapshot: ready,
      batch: batch,
      actionPhrase: 'scheduled',
      forceActiveTab: batch.hasSuccesses
          ? InterviewCandidateTab.scheduled
          : ready.activeTab,
    );
  }

  Future<void> _onSelectSubmitted(
    InterviewSelectSubmitted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    if (event.candidateIds.isEmpty) return;
    final ready = _readyOrNull(state);
    if (ready == null) return;
    if (!ready.activeRound.usesEligibleScheduledTabs ||
        ready.activeTab != InterviewCandidateTab.scheduled) {
      return;
    }

    final batch = await repository.selectAfterInterview(
      event.candidateIds,
      ready.activeRound,
    );

    await _emitAfterMutation(
      emit: emit,
      snapshot: ready,
      batch: batch,
      actionPhrase: 'moved to the next stage',
    );
  }

  Future<void> _onRejectSubmitted(
    InterviewRejectSubmitted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    if (event.candidateIds.isEmpty) return;
    final ready = _readyOrNull(state);
    if (ready == null) return;
    final from = ready.activeRound;
    if (from == InterviewRound.rejected) return;

    final batch = await repository.rejectInterviews(event.candidateIds, from);

    await _emitAfterMutation(
      emit: emit,
      snapshot: ready,
      batch: batch,
      actionPhrase: 'rejected',
    );
  }

  Future<void> _onOnboardSubmitted(
    InterviewOnboardSubmitted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    if (event.candidateIds.isEmpty) return;
    final ready = _readyOrNull(state);
    if (ready == null) return;
    if (ready.activeRound != InterviewRound.selected) return;

    final batch = await repository.onboardFromSelected(event.candidateIds);

    await _emitAfterMutation(
      emit: emit,
      snapshot: ready,
      batch: batch,
      actionPhrase: 'moved to onboarding',
    );
  }

  Future<void> _onFlushSubmitted(
    InterviewFlushSubmitted event,
    Emitter<InterviewSchedulingState> emit,
  ) async {
    if (event.candidateIds.isEmpty) return;
    final ready = _readyOrNull(state);
    if (ready == null) return;
    if (ready.activeRound != InterviewRound.onboarding) return;

    final batch =
        await repository.flushOnboardingToEmployees(event.candidateIds);

    await _emitAfterMutation(
      emit: emit,
      snapshot: ready,
      batch: batch,
      actionPhrase: 'removed from pipeline',
    );
  }

  void _onSearchChanged(
    InterviewSearchChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(_applyFilters(ready.copyWith(searchQuery: event.query)));
  }

  void _onFiltersApplied(
    InterviewFiltersApplied event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(
      _applyFilters(
        ready.copyWith(
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
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(
      _applyFilters(
        ready.copyWith(
          selectedJob: kAllJobs,
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
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(_applyFilters(ready.copyWith(activeTab: event.tab)));
  }

  void _onRoundChanged(
    InterviewRoundChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(_applyFilters(ready.copyWith(activeRound: event.round)));
  }

  void _onSelectionChanged(
    InterviewSelectionChanged event,
    Emitter<InterviewSchedulingState> emit,
  ) {
    final ready = _readyOrNull(state);
    if (ready == null) return;
    emit(ready.copyWith(selectedIds: event.selectedIds));
  }

  String _errorMessage(Object e) {
    if (e is RemoteDataException) return e.message;
    return e.toString();
  }

  String _batchMutationToast(
    InterviewBatchMutationResult r,
    String actionPhrase,
  ) {
    if (!r.hasFailures) return '';
    final failCount = r.failures.length;
    final okCount = r.succeededApplicationIds.length;
    final first = r.failures.first.message;
    if (okCount == 0) {
      return failCount == 1
          ? first
          : 'None could be $actionPhrase ($failCount failed). $first';
    }
    return '$okCount succeeded, $failCount could not be $actionPhrase. $first';
  }

  InterviewSchedulingReady _applyFilters(
    InterviewSchedulingReady targetState,
  ) {
    final search = targetState.searchQuery.toLowerCase().trim();
    final filtered = targetState.candidates.where((candidate) {
      if (candidate.pipelineRound != targetState.activeRound) {
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

      if (targetState.activeRound.usesEligibleScheduledTabs) {
        if (targetState.activeTab == InterviewCandidateTab.eligible &&
            candidate.isScheduled) {
          return false;
        }
        if (targetState.activeTab == InterviewCandidateTab.scheduled &&
            !candidate.isScheduled) {
          return false;
        }
      }
      return true;
    }).toList();

    final visibleIds = filtered.map((c) => c.id).toSet();
    final selectedIds =
        targetState.selectedIds.where((id) => visibleIds.contains(id)).toSet();

    return targetState.copyWith(
      filteredCandidates: filtered,
      selectedIds: selectedIds,
    );
  }
}
