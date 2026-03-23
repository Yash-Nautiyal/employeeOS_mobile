import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/repositories/interview_scheduling_repository.dart';

class GetInterviewCandidatesUseCase {
  final InterviewSchedulingRepository repository;

  const GetInterviewCandidatesUseCase(this.repository);

  Future<List<InterviewCandidate>> call(String jobId) {
    return repository.fetchCandidates(jobId);
  }
}
