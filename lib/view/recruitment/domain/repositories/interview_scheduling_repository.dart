import 'package:employeeos/view/recruitment/domain/entities/interview_candidate.dart';

abstract class InterviewSchedulingRepository {
  Future<List<InterviewCandidate>> fetchCandidates();
}

