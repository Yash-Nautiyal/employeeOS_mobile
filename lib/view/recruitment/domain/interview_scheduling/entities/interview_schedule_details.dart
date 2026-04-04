import 'package:equatable/equatable.dart';

/// Data collected when marking interviews scheduled (persisted to `interviews`).
class InterviewScheduleDetails extends Equatable {
  const InterviewScheduleDetails({
    required this.scheduleStart,
    required this.interviewerLabel,
    required this.assignedByLabel,
  });

  /// Stored as `timestamptz` (pass UTC or local; datasource converts).
  final DateTime scheduleStart;

  final String interviewerLabel;
  final String assignedByLabel;

  @override
  List<Object?> get props => [scheduleStart, interviewerLabel, assignedByLabel];
}
