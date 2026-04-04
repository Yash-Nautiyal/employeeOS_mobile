import 'package:equatable/equatable.dart';

/// Result of a batch update against `interviews` (per application id).
///
/// The UI should **refetch** after receiving this so lists match the database;
/// [succeededApplicationIds] and [failures] explain what happened per id.
class InterviewBatchMutationResult extends Equatable {
  const InterviewBatchMutationResult({
    required this.succeededApplicationIds,
    required this.failures,
  });

  final List<String> succeededApplicationIds;
  final List<InterviewBatchFailure> failures;

  bool get hasFailures => failures.isNotEmpty;

  bool get hasSuccesses => succeededApplicationIds.isNotEmpty;

  static const InterviewBatchMutationResult empty =
      InterviewBatchMutationResult(
    succeededApplicationIds: [],
    failures: [],
  );

  @override
  List<Object?> get props => [succeededApplicationIds, failures];
}

class InterviewBatchFailure extends Equatable {
  const InterviewBatchFailure({
    required this.applicationId,
    required this.message,
  });

  final String applicationId;
  final String message;

  @override
  List<Object?> get props => [applicationId, message];
}
