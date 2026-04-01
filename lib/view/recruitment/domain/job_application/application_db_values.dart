abstract final class ApplicationDbStatus {
  static const pending = 'pending';
  static const shortlisted = 'shortlisted';
  static const rejected = 'rejected';
}

abstract final class ApplicationPipelineStage {
  ApplicationPipelineStage._();

  static const firstInterviewRound = 'telephone';
}

abstract final class ApplicationStatusActions {
  ApplicationStatusActions._();

  static String normalize(String? raw) => raw?.trim().toLowerCase() ?? '';

  static bool canUpdateStatus(String? status) {
    final s = normalize(status);
    return s == ApplicationDbStatus.pending || s == 'applied' || s.isEmpty;
  }
}
