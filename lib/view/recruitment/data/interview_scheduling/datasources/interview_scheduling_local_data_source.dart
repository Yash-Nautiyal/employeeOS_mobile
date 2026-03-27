
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
    required String jobTitle,
    required DateTime appliedOn,
    required String jobId,
  }) async {
    final idx = _candidates.indexWhere((c) => c.id == applicationId);
    final row = InterviewCandidateModel(
      id: applicationId,
      name: fullName,
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

  static List<InterviewCandidateModel> _buildSeed() {
    InterviewCandidateModel row({
      required String id,
      required String name,
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
        jobTitle: 'Frontend Developer',
        applicationDate: DateTime(2025, 4, 14),
        interviewDate: DateTime(2025, 4, 14),
        jobId: 'FE-03',
        interviewer: 'Alex Chen',
        status: 'Scheduled',
        pipelineRound: InterviewRound.telephone,
      ),
      row(
        id: '4',
        name: 'Rahul Kumar',
        jobTitle: 'Backend Developer',
        applicationDate: DateTime(2025, 4, 13),
        interviewDate: DateTime(2025, 4, 13),
        jobId: 'BE-04',
        interviewer: 'Sam Lee',
        status: 'Eligible',
        pipelineRound: InterviewRound.technical,
      ),
      row(
        id: '5',
        name: 'Anjali Gupta',
        jobTitle: 'DevOps Engineer',
        applicationDate: DateTime(2025, 4, 12),
        interviewDate: DateTime(2025, 4, 12),
        jobId: 'DEV-05',
        interviewer: 'Maria Garcia',
        status: 'Scheduled',
        pipelineRound: InterviewRound.technical,
      ),
      row(
        id: '6',
        name: 'Vikram Singh',
        jobTitle: 'Data Analyst',
        applicationDate: DateTime(2025, 4, 11),
        interviewDate: DateTime(2025, 4, 11),
        jobId: 'DA-06',
        interviewer: 'Sam Lee',
        status: 'Selected',
        pipelineRound: InterviewRound.selected,
      ),
      row(
        id: '7',
        name: 'Sneha Patel',
        jobTitle: 'UI/UX Designer',
        applicationDate: DateTime(2025, 4, 10),
        interviewDate: DateTime(2025, 4, 10),
        jobId: 'UX-07',
        interviewer: 'Alex Chen',
        status: 'Onboarding',
        pipelineRound: InterviewRound.onboarding,
      ),
      row(
        id: '8',
        name: 'Amit Verma',
        jobTitle: 'Mobile Developer',
        applicationDate: DateTime(2025, 4, 9),
        interviewDate: DateTime(2025, 4, 9),
        jobId: 'MB-08',
        interviewer: 'Maria Garcia',
        status: 'Rejected',
        pipelineRound: InterviewRound.rejected,
        rejectedFromRound: InterviewRound.telephone,
      ),
      row(
        id: '9',
        name: 'Kavita Rao',
        jobTitle: 'QA Engineer',
        applicationDate: DateTime(2025, 4, 8),
        interviewDate: DateTime(2025, 4, 8),
        jobId: 'QA-09',
        interviewer: 'Sam Lee',
        status: 'Rejected',
        pipelineRound: InterviewRound.rejected,
        rejectedFromRound: InterviewRound.technical,
      ),
    ];
  }
}
