import 'package:employeeos/view/recruitment/domain/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/repositories/interview_scheduling_repository.dart';

class GetInterviewCandidatesUseCase {
  final InterviewSchedulingRepository repository;

  const GetInterviewCandidatesUseCase(this.repository);

  Future<List<InterviewCandidate>> call() {
    return repository.fetchCandidates();
  }
}
