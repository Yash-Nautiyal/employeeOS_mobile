import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';

/// `public.interviews.stage` (lowercase). See INTERVIEW_PIPELINE_DB_AND_ENUMS.md.
abstract final class InterviewDbStage {
  InterviewDbStage._();

  static const telephone = 'telephone';
  static const technical = 'technical';
  static const selected = 'selected';
  static const onboarding = 'onboarding';
}

/// `public.interviews.status` (lowercase).
abstract final class InterviewDbStatus {
  InterviewDbStatus._();

  static const eligible = 'eligible';
  static const scheduled = 'scheduled';
  static const rejected = 'rejected';
  static const passed = 'passed';
}

/// Maps UI round tabs to DB `stage` (excludes [InterviewRound.rejected]).
String interviewRoundToDbStage(InterviewRound round) {
  switch (round) {
    case InterviewRound.telephone:
      return InterviewDbStage.telephone;
    case InterviewRound.technical:
      return InterviewDbStage.technical;
    case InterviewRound.selected:
      return InterviewDbStage.selected;
    case InterviewRound.onboarding:
      return InterviewDbStage.onboarding;
    case InterviewRound.rejected:
      return InterviewDbStage.telephone;
  }
}

InterviewRound? interviewDbStageToRound(String? raw) {
  final s = raw?.trim().toLowerCase() ?? '';
  switch (s) {
    case InterviewDbStage.telephone:
      return InterviewRound.telephone;
    case InterviewDbStage.technical:
      return InterviewRound.technical;
    case InterviewDbStage.selected:
      return InterviewRound.selected;
    case InterviewDbStage.onboarding:
      return InterviewRound.onboarding;
    default:
      return null;
  }
}
