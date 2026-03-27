import '../../../domain/index.dart'
    show InterviewCandidate, InterviewRound, InterviewSchedulingRepository;
import '../../index.dart' show JobApplicationMockDatasource;
import '../datasources/interview_scheduling_local_data_source.dart';

class InterviewSchedulingRepositoryImpl
    implements InterviewSchedulingRepository {
  final InterviewSchedulingLocalDataSource localDataSource;

  const InterviewSchedulingRepositoryImpl(this.localDataSource);

  static bool _mergedShortlistedFromApplications = false;

  @override
  Future<List<InterviewCandidate>> fetchCandidates() async {
    if (!_mergedShortlistedFromApplications) {
      _mergedShortlistedFromApplications = true;
      final apps =
          await JobApplicationMockDatasource.instance.getApplications();
      for (final a in apps) {
        if (a.status != 'Shortlisted') continue;
        await localDataSource.syncEligibleFromShortlistedApplication(
          applicationId: a.id,
          fullName: a.fullName,
          jobTitle: a.jobTitle,
          appliedOn: a.appliedOn,
          jobId: a.jobId,
        );
      }
    }
    return localDataSource.fetchCandidates();
  }

  @override
  Future<void> scheduleInterviews(Set<String> ids, InterviewRound round) {
    return localDataSource.scheduleInterviews(ids, round);
  }

  @override
  Future<void> selectAfterInterview(Set<String> ids, InterviewRound round) {
    return localDataSource.selectAfterInterview(ids, round);
  }

  @override
  Future<void> rejectInterviews(Set<String> ids, InterviewRound fromRound) {
    return localDataSource.rejectInterviews(ids, fromRound);
  }

  @override
  Future<void> onboardFromSelected(Set<String> ids) {
    return localDataSource.onboardFromSelected(ids);
  }
}
