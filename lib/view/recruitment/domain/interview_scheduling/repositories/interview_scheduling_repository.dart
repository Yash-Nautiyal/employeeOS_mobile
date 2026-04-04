import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_batch_mutation_result.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_schedule_details.dart';

abstract class InterviewSchedulingRepository {
  Future<List<InterviewCandidate>> fetchCandidates();

  Future<InterviewBatchMutationResult> scheduleInterviews(
    Set<String> applicationIds,
    InterviewRound round,
    InterviewScheduleDetails details,
  );

  Future<InterviewBatchMutationResult> selectAfterInterview(
    Set<String> ids,
    InterviewRound round,
  );

  Future<InterviewBatchMutationResult> rejectInterviews(
    Set<String> ids,
    InterviewRound fromRound,
  );

  Future<InterviewBatchMutationResult> onboardFromSelected(Set<String> ids);

  Future<InterviewBatchMutationResult> flushOnboardingToEmployees(
    Set<String> ids,
  );
}
