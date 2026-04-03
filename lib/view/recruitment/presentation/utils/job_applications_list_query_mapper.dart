import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';

import 'job_application_filter_logic.dart';

/// Page size for job applications list (server + UI).
const int kJobApplicationsPageSize = 10;

JobApplicationsListQuery listQueryFromFilterCriteria(
  JobApplicationFilterCriteria criteria, {
  int page = 1,
  int pageSize = kJobApplicationsPageSize,
}) {
  DateTime? start;
  DateTime? endEx;
  if (criteria.dateRange != null) {
    start = DateTime(
      criteria.dateRange!.start.year,
      criteria.dateRange!.start.month,
      criteria.dateRange!.start.day,
    );
    endEx = DateTime(
      criteria.dateRange!.end.year,
      criteria.dateRange!.end.month,
      criteria.dateRange!.end.day,
    ).add(const Duration(days: 1));
  }
  return JobApplicationsListQuery(
    searchQuery: criteria.searchQuery,
    jobId: criteria.jobId,
    hrQuery: criteria.hrQuery,
    joinImmediate: criteria.joinImmediate,
    joinAfterMonths: criteria.joinAfterMonths,
    jobType: criteria.jobType,
    applicationStatus: criteria.applicationStatus,
    dateRangeStart: start,
    dateRangeEndExclusive: endEx,
    sortAscending: criteria.sortBy != 'Latest',
    page: page,
    pageSize: pageSize,
  );
}
