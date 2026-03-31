import '../../../domain/index.dart' show InterviewRound;
import '../models/interview_candidate_model.dart';

class InterviewSchedulingLocalDataSource {
  InterviewSchedulingLocalDataSource._() {
    _candidates = _buildSeed();
  }

  static final InterviewSchedulingLocalDataSource instance =
      InterviewSchedulingLocalDataSource._();

  late List<InterviewCandidateModel> _candidates;

  Future<List<InterviewCandidateModel>> fetchCandidates() async {
    return List<InterviewCandidateModel>.from(_candidates);
  }

  /// Eligible → scheduled (same round).
  Future<void> scheduleInterviews(
    Set<String> ids,
    InterviewRound round,
  ) async {
    for (var i = 0; i < _candidates.length; i++) {
      final c = _candidates[i];
      if (!ids.contains(c.id)) continue;
      if (c.pipelineRound != round) continue;
      if (c.isScheduled) continue;
      _candidates[i] = c.copyWith(
        status: 'Scheduled',
        interviewDate: DateTime.now().add(const Duration(days: 3)),
      );
    }
  }

  /// After interview: telephone → technical eligible; technical → selected.
  Future<void> selectAfterInterview(
    Set<String> ids,
    InterviewRound round,
  ) async {
    for (var i = 0; i < _candidates.length; i++) {
      final c = _candidates[i];
      if (!ids.contains(c.id)) continue;
      if (c.pipelineRound != round) continue;
      if (!c.isScheduled) continue;

      if (round == InterviewRound.telephone) {
        _candidates[i] = c.copyWith(
          pipelineRound: InterviewRound.technical,
          status: 'Eligible',
          clearRejectedFromRound: true,
        );
      } else if (round == InterviewRound.technical) {
        _candidates[i] = c.copyWith(
          pipelineRound: InterviewRound.selected,
          status: 'Selected',
          clearRejectedFromRound: true,
        );
      }
    }
  }

  Future<void> rejectInterviews(
    Set<String> ids,
    InterviewRound fromRound,
  ) async {
    for (var i = 0; i < _candidates.length; i++) {
      final c = _candidates[i];
      if (!ids.contains(c.id)) continue;
      if (c.pipelineRound != fromRound) continue;

      _candidates[i] = c.copyWith(
        pipelineRound: InterviewRound.rejected,
        status: 'Rejected',
        rejectedFromRound: fromRound,
      );
    }
  }

  /// Selected tab → onboarding round.
  /// When an application is shortlisted in Job Application, mirror it here as
  /// telephone / Eligible so Interview Scheduling shows the same candidate.
  Future<void> syncEligibleFromShortlistedApplication({
    required String applicationId,
    required String fullName,
    required String email,
    required String jobTitle,
    required DateTime appliedOn,
    required String jobId,
  }) async {
    final idx = _candidates.indexWhere((c) => c.id == applicationId);
    final row = InterviewCandidateModel(
      id: applicationId,
      name: fullName,
      email: email,
      jobTitle: jobTitle,
      applicationDate: appliedOn,
      interviewDate: appliedOn,
      jobId: jobId,
      interviewer: '—',
      status: 'Eligible',
      pipelineRound: InterviewRound.telephone,
      rejectedFromRound: null,
    );
    if (idx >= 0) {
      _candidates[idx] = row;
    } else {
      _candidates.add(row);
    }
  }

  Future<void> onboardFromSelected(Set<String> ids) async {
    for (var i = 0; i < _candidates.length; i++) {
      final c = _candidates[i];
      if (!ids.contains(c.id)) continue;
      if (c.pipelineRound != InterviewRound.selected) continue;

      _candidates[i] = c.copyWith(
        pipelineRound: InterviewRound.onboarding,
        status: 'Onboarding',
        clearRejectedFromRound: true,
      );
    }
  }

  /// Onboarding tab "flush": candidates are now employees, so remove from
  /// interview pipeline table.
  Future<void> flushOnboardingToEmployees(Set<String> ids) async {
    _candidates.removeWhere(
      (c) => ids.contains(c.id) && c.pipelineRound == InterviewRound.onboarding,
    );
  }

  static List<InterviewCandidateModel> _buildSeed() {
    InterviewCandidateModel row({
      required String id,
      required String name,
      required String email,
      required String jobTitle,
      required DateTime applicationDate,
      required DateTime interviewDate,
      required String jobId,
      required String interviewer,
      required String status,
      required InterviewRound pipelineRound,
      InterviewRound? rejectedFromRound,
    }) {
      return InterviewCandidateModel(
        id: id,
        name: name,
        email: email,
        jobTitle: jobTitle,
        applicationDate: applicationDate,
        interviewDate: interviewDate,
        jobId: jobId,
        interviewer: interviewer,
        status: status,
        pipelineRound: pipelineRound,
        rejectedFromRound: rejectedFromRound,
      );
    }

    return [
      row(
        id: '1',
        name: 'Yash katara',
        email: 'itscrzy45@gmail.com',
        jobTitle: 'AWS Cloud Intern',
        applicationDate: DateTime(2025, 4, 16),
        interviewDate: DateTime(2025, 4, 16),
        jobId: 'AWS-01',
        interviewer: 'Alex Chen',
        status: 'Eligible',
        pipelineRound: InterviewRound.telephone,
      ),
      row(
        id: '2',
        name: 'Lakshman Reddy Thummala',
        email: 'ynautiyal811@gmail.com',
        jobTitle: 'Full Stack Developer',
        applicationDate: DateTime(2025, 4, 15),
        interviewDate: DateTime(2025, 4, 15),
        jobId: 'FS-02',
        interviewer: 'Maria Garcia',
        status: 'Eligible',
        pipelineRound: InterviewRound.telephone,
      ),
      row(
        id: '3',
        name: 'Priya Sharma',
        email: 'yashnautiyal04@gmail.com',
        jobTitle: 'Frontend Developer',
        applicationDate: DateTime(2025, 4, 14),
        interviewDate: DateTime(2025, 4, 14),
        jobId: 'FE-03',
        interviewer: 'Alex Chen',
        status: 'Scheduled',
        pipelineRound: InterviewRound.telephone,
      ),
    ];
  }
}
