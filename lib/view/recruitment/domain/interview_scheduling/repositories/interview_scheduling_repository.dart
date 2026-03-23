import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';

abstract class InterviewSchedulingRepository {
  Future<List<InterviewCandidate>> fetchCandidates(String jobId);
}
