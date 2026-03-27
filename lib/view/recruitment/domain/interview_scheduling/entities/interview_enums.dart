enum InterviewRound {
  telephone,
  technical,
  onboarding,
  selected,
  rejected,
}

extension InterviewRoundLabel on InterviewRound {
  String get label {
    switch (this) {
      case InterviewRound.telephone:
        return 'Telephone Round';
      case InterviewRound.technical:
        return 'Technical Round';
      case InterviewRound.onboarding:
        return 'Onboarding';
      case InterviewRound.selected:
        return 'Selected';
      case InterviewRound.rejected:
        return 'Rejected';
    }
  }

  /// Eligible / Scheduled sub-tabs apply only to main interview rounds (see RECRUITMENT_INTERVIEW_FLOW.md).
  bool get usesEligibleScheduledTabs =>
      this == InterviewRound.telephone || this == InterviewRound.technical;
}

enum InterviewCandidateTab {
  eligible,
  scheduled,
}
