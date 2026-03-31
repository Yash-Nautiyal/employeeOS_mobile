import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';

/// Display name used in Calendar event title/description (matches web copy).
const String kCompanyNameCalendar = 'F13 Technologies';

String buildCalendarEventTitle(InterviewRound round) =>
    'Interview with $kCompanyNameCalendar - ${round.label}';

/// e.g. "Telephone interview round with F13 Technologies"
String buildRoundInterviewHeadingLine(InterviewRound round) {
  final head = switch (round) {
    InterviewRound.telephone => 'Telephone',
    InterviewRound.technical => 'Technical',
    InterviewRound.onboarding => 'Onboarding',
    InterviewRound.selected => 'Selected',
    InterviewRound.rejected => 'Rejected',
  };
  return '$head interview round with $kCompanyNameCalendar';
}

/// Four-block description: heading, interviewer, assigned by, candidates.
String buildCalendarEventDetails({
  required InterviewRound round,
  required String interviewerName,
  required String assignedByName,
  required int selectedCount,
  String candidateNamesSummary = '',
}) {
  final lines = <String>[
    buildRoundInterviewHeadingLine(round),
    '',
    'Interviewer: $interviewerName',
    'Assigned by: $assignedByName',
    '',
    if (candidateNamesSummary.trim().isNotEmpty)
      'Candidate(s): ${candidateNamesSummary.trim()}'
    else
      'Selected candidates: $selectedCount',
  ];
  return lines.join('\n');
}
