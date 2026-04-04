import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import 'package:flutter/material.dart';

class JobPostingFilterCriteria {
  const JobPostingFilterCriteria({
    this.searchQuery = '',
    this.jobId = '',
    this.hrQuery = '',
    this.joinImmediate = false,
    this.joinAfterMonths = false,
    this.jobType = 'All',
    this.dateRange,
    this.sortBy = 'Latest',
  });

  final String searchQuery;
  final String jobId;
  final String hrQuery;
  final bool joinImmediate;
  final bool joinAfterMonths;
  final String jobType;
  final DateTimeRange? dateRange;
  final String sortBy;
}

List<JobPosting> applyJobPostingFiltersAndSort(
  List<JobPosting> jobs,
  JobPostingFilterCriteria criteria,
) {
  final search = criteria.searchQuery.trim().toLowerCase();
  var filtered = jobs.where((job) {
    if (search.isNotEmpty) {
      final hay = '${job.title} ${job.department} ${job.id}'.toLowerCase();
      if (!hay.contains(search)) return false;
    }

    if (criteria.jobId.isNotEmpty && job.id != criteria.jobId) {
      return false;
    }

    if (criteria.hrQuery.trim().isNotEmpty) {
      final hrNeedle = criteria.hrQuery.trim().toLowerCase();
      final hrHay = '${job.postedByName} ${job.postedByEmail}'.toLowerCase();
      if (!hrHay.contains(hrNeedle)) return false;
    }

    if (criteria.joinImmediate || criteria.joinAfterMonths) {
      final jt = job.joiningType.toLowerCase();
      final isImmediate = jt == 'immediate';
      final isAfterMonths = jt == 'notice period' ||
          jt == 'flexible' ||
          jt == 'after_months' ||
          jt.contains('month');
      final joinMatch = (criteria.joinImmediate && isImmediate) ||
          (criteria.joinAfterMonths && isAfterMonths);
      if (!joinMatch) return false;
    }

    if (criteria.jobType != 'All') {
      if (criteria.jobType == 'Internship' && !job.isInternship) return false;
      if (criteria.jobType == 'Full-time' && job.isInternship) return false;
    }

    if (criteria.dateRange != null) {
      final d = job.createdAt ?? job.lastDateToApply;
      if (d == null) return false;
      final inRange = !d.isBefore(criteria.dateRange!.start) &&
          !d.isAfter(criteria.dateRange!.end);
      if (!inRange) return false;
    }
    return true;
  }).toList();

  if (criteria.sortBy == 'Latest') {
    filtered.sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
  } else if (criteria.sortBy == 'Oldest') {
    filtered.sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ad.compareTo(bd);
    });
  }

  return filtered;
}
