import 'package:flutter/material.dart';

import '../../../../domain/index.dart' show JobApplication, JobPosting;
import '../../../../domain/job_application/application_db_values.dart'
    show ApplicationDbStatus, ApplicationStatusActions;

/// Filter + sort state for the job applications list (kept out of the page widget).
class JobApplicationFilterCriteria {
  const JobApplicationFilterCriteria({
    this.searchQuery = '',
    this.jobId = '',
    this.hrQuery = '',
    this.joinImmediate = false,
    this.joinAfterMonths = false,
    this.jobType = 'All',
    this.applicationStatus = '',
    this.dateRange,
    this.sortBy = 'Latest',
  });

  final String searchQuery;
  final String jobId;
  final String hrQuery;
  final bool joinImmediate;
  final bool joinAfterMonths;
  final String jobType;

  /// Normalized: `''` = all, else `pending` | `shortlisted` | `rejected`.
  final String applicationStatus;
  final DateTimeRange? dateRange;
  final String sortBy;
}

JobPosting? jobPostingForApplication(
  JobApplication application,
  List<JobPosting> jobs,
) {
  for (final j in jobs) {
    if (j.id == application.jobId) return j;
  }
  return null;
}

/// Applies search, job panel filters (via [jobs] for joining type / internship / HR on poster), status, date, and sort.
List<JobApplication> applyJobApplicationFiltersAndSort(
  List<JobApplication> applications,
  JobApplicationFilterCriteria criteria,
  List<JobPosting> jobs,
) {
  final search = criteria.searchQuery.trim().toLowerCase();
  var list = applications.where((a) {
    if (search.isNotEmpty) {
      final hay =
          '${a.fullName} ${a.email} ${a.jobTitle} ${a.id}'.toLowerCase();
      if (!hay.contains(search)) return false;
    }

    if (criteria.jobId.isNotEmpty && a.jobId != criteria.jobId) {
      return false;
    }

    final job = jobPostingForApplication(a, jobs);

    if (criteria.hrQuery.trim().isNotEmpty) {
      final needle = criteria.hrQuery.trim().toLowerCase();
      final hay = job != null
          ? '${job.postedByName} ${job.postedByEmail}'.toLowerCase()
          : '';
      if (!hay.contains(needle)) return false;
    }

    if (criteria.joinImmediate || criteria.joinAfterMonths) {
      if (job == null) return false;
      final jt = job.joiningType.toLowerCase();
      final isImmediate = jt == 'immediate';
      // Matches add/edit job UIs: immediate | notice period | flexible (+ legacy strings).
      final isAfterMonths = jt == 'notice period' ||
          jt == 'flexible' ||
          jt == 'after_months' ||
          jt.contains('month');
      final joinMatch = (criteria.joinImmediate && isImmediate) ||
          (criteria.joinAfterMonths && isAfterMonths);
      if (!joinMatch) return false;
    }

    if (criteria.jobType != 'All') {
      if (job == null) return false;
      if (criteria.jobType == 'Internship' && !job.isInternship) return false;
      if (criteria.jobType == 'Full-time' && job.isInternship) return false;
    }

    if (criteria.applicationStatus.isNotEmpty) {
      final appSt = ApplicationStatusActions.normalize(a.status);
      final want = criteria.applicationStatus;
      final match = appSt == want ||
          (want == ApplicationDbStatus.pending &&
              (appSt == 'applied' || appSt.isEmpty));
      if (!match) return false;
    }

    if (criteria.dateRange != null) {
      final start = DateTime(
        criteria.dateRange!.start.year,
        criteria.dateRange!.start.month,
        criteria.dateRange!.start.day,
      );
      final end = DateTime(
        criteria.dateRange!.end.year,
        criteria.dateRange!.end.month,
        criteria.dateRange!.end.day,
      ).add(const Duration(days: 1));
      final t = DateTime(a.appliedOn.year, a.appliedOn.month, a.appliedOn.day);
      if (t.isBefore(start) || !t.isBefore(end)) return false;
    }

    return true;
  }).toList();

  list.sort((a, b) {
    final cmp = a.appliedOn.compareTo(b.appliedOn);
    return criteria.sortBy == 'Latest' ? -cmp : cmp;
  });

  return list;
}
