class HiringFilterParams {
  final String? jobId;
  final String? hrManagerId;
  final DateTime? postingFrom;
  final DateTime? postingTo;
  final String? deadlineFrom;
  final String? deadlineTo;

  const HiringFilterParams({
    this.jobId,
    this.hrManagerId,
    this.postingFrom,
    this.postingTo,
    this.deadlineFrom,
    this.deadlineTo,
  });

  static const HiringFilterParams empty = HiringFilterParams();
}
