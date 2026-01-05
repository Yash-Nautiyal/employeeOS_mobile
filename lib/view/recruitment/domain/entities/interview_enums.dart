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
}

enum InterviewCandidateTab {
  eligible,
  scheduled,
}

