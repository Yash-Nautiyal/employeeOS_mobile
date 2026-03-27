import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';

abstract class InterviewSchedulingRepository {
  Future<List<InterviewCandidate>> fetchCandidates();

  Future<void> scheduleInterviews(Set<String> ids, InterviewRound round);

  Future<void> selectAfterInterview(Set<String> ids, InterviewRound round);

  Future<void> rejectInterviews(Set<String> ids, InterviewRound fromRound);

  Future<void> onboardFromSelected(Set<String> ids);
}
