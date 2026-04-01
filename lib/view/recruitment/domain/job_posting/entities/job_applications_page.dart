import 'package:equatable/equatable.dart';

import 'job_application_summary.dart';

class JobApplicationsPage extends Equatable {
  const JobApplicationsPage({
    required this.items,
    required this.totalCount,
    required this.offset,
    required this.limit,
  });

  final List<JobApplicationSummary> items;
  final int totalCount;
  final int offset;
  final int limit;

  int get currentPage => (offset ~/ limit) + 1;
  int get totalPages => totalCount == 0 ? 1 : ((totalCount - 1) ~/ limit) + 1;
  bool get hasPrevious => offset > 0;
  bool get hasNext => offset + items.length < totalCount;

  @override
  List<Object?> get props => [items, totalCount, offset, limit];
}
