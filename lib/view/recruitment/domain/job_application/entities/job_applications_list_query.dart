import 'package:equatable/equatable.dart';

/// Server-side filter + sort + pagination for the global applications list.
class JobApplicationsListQuery extends Equatable {
  const JobApplicationsListQuery({
    this.searchQuery = '',
    this.jobId = '',
    this.hrQuery = '',
    this.joinImmediate = false,
    this.joinAfterMonths = false,
    this.jobType = 'All',
    this.applicationStatus = '',
    this.dateRangeStart,
    this.dateRangeEndExclusive,
    this.sortAscending = false,
    this.page = 1,
    this.pageSize = 10,
  });

  final String searchQuery;
  final String jobId;
  final String hrQuery;
  final bool joinImmediate;
  final bool joinAfterMonths;
  final String jobType;

  /// Normalized: `''` = all, else `pending` | `shortlisted` | `rejected`.
  final String applicationStatus;

  /// Inclusive start (date only).
  final DateTime? dateRangeStart;

  /// Exclusive end (day after last selected day).
  final DateTime? dateRangeEndExclusive;

  /// `false` = latest first (`created_at` desc).
  final bool sortAscending;

  final int page;
  final int pageSize;

  int get offset => (page - 1) * pageSize;

  JobApplicationsListQuery copyWith({
    String? searchQuery,
    String? jobId,
    String? hrQuery,
    bool? joinImmediate,
    bool? joinAfterMonths,
    String? jobType,
    String? applicationStatus,
    DateTime? dateRangeStart,
    DateTime? dateRangeEndExclusive,
    bool? sortAscending,
    int? page,
    int? pageSize,
    bool clearDateRange = false,
  }) {
    return JobApplicationsListQuery(
      searchQuery: searchQuery ?? this.searchQuery,
      jobId: jobId ?? this.jobId,
      hrQuery: hrQuery ?? this.hrQuery,
      joinImmediate: joinImmediate ?? this.joinImmediate,
      joinAfterMonths: joinAfterMonths ?? this.joinAfterMonths,
      jobType: jobType ?? this.jobType,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      dateRangeStart:
          clearDateRange ? null : (dateRangeStart ?? this.dateRangeStart),
      dateRangeEndExclusive: clearDateRange
          ? null
          : (dateRangeEndExclusive ?? this.dateRangeEndExclusive),
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        jobId,
        hrQuery,
        joinImmediate,
        joinAfterMonths,
        jobType,
        applicationStatus,
        dateRangeStart,
        dateRangeEndExclusive,
        sortAscending,
        page,
        pageSize,
      ];
}
