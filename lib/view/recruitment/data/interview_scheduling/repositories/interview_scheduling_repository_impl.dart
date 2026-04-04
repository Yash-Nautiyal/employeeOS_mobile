import 'package:employeeos/view/recruitment/domain/index.dart'
    show
        InterviewBatchMutationResult,
        InterviewCandidate,
        InterviewRound,
        InterviewScheduleDetails,
        InterviewSchedulingRepository;

import '../datasources/interview_scheduling_remote_datasource.dart';

class InterviewSchedulingRepositoryImpl
    implements InterviewSchedulingRepository {
  InterviewSchedulingRepositoryImpl(this._remote);

  final InterviewSchedulingRemoteDatasource _remote;

  @override
  Future<List<InterviewCandidate>> fetchCandidates() {
    return _remote.fetchPipelineRows();
  }

  @override
  Future<InterviewBatchMutationResult> scheduleInterviews(
    Set<String> applicationIds,
    InterviewRound round,
    InterviewScheduleDetails details,
  ) {
    return _remote.scheduleApplications(applicationIds, round, details);
  }

  @override
  Future<InterviewBatchMutationResult> selectAfterInterview(
    Set<String> ids,
    InterviewRound round,
  ) {
    return _remote.advanceAfterInterview(ids, round);
  }

  @override
  Future<InterviewBatchMutationResult> rejectInterviews(
    Set<String> ids,
    InterviewRound fromRound,
  ) {
    return _remote.rejectApplications(ids, fromRound);
  }

  @override
  Future<InterviewBatchMutationResult> onboardFromSelected(Set<String> ids) {
    return _remote.onboardApplications(ids);
  }

  @override
  Future<InterviewBatchMutationResult> flushOnboardingToEmployees(
    Set<String> ids,
  ) {
    return _remote.flushOnboarding(ids);
  }
}
