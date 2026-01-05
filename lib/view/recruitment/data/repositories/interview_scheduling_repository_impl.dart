import 'package:employeeos/view/recruitment/data/datasources/interview_scheduling_local_data_source.dart';
import 'package:employeeos/view/recruitment/domain/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/repositories/interview_scheduling_repository.dart';

class InterviewSchedulingRepositoryImpl implements InterviewSchedulingRepository {
  final InterviewSchedulingLocalDataSource localDataSource;

  const InterviewSchedulingRepositoryImpl(this.localDataSource);

  @override
  Future<List<InterviewCandidate>> fetchCandidates() async {
    return localDataSource.fetchCandidates();
  }
}

