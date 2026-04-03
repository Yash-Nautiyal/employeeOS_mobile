import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';

class JobApplicationsListResult {
  const JobApplicationsListResult({
    required this.items,
    required this.totalCount,
  });

  final List<JobApplication> items;
  final int totalCount;

  int totalPages(int pageSize) =>
      pageSize <= 0 ? 0 : (totalCount + pageSize - 1) ~/ pageSize;
}
