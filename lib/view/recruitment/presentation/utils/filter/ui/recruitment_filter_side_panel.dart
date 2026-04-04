import 'package:employeeos/core/index.dart' show showRightSideTaskDetails;
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import 'package:flutter/material.dart';

import '../../../widget/job_posting/components/filter/job_filter_panel.dart';

// --- Filter flow (read this if the panel feels "lost") -----------------------
//
// **Job posting:** The side panel only edits local UI state on this screen.
// The list is whatever [JobPostingBloc] already loaded; [applyJobPostingFiltersAndSort]
// in `job_posting_filter_logic.dart` narrows that list in memory (no new network call
// when you tap Apply).
//
// **Job applications:** The same panel edits the same *shape* of filters, but those
// values are turned into [JobApplicationsListQuery] by `listQueryFromFilterCriteria`
// and sent to Supabase when you Apply or Reset (refetch page 1).
//
// Shared UI: [JobPostingFilterPanel] (job + **HR name** dropdowns from [jobs]).
// Extra row: set [showApplicationStatusFilter].
// -----------------------------------------------------------------------------

/// Values mirrored by [JobPostingFilterPanel] (apply / reset).
@immutable
class RecruitmentFilterSelection {
  const RecruitmentFilterSelection({
    this.jobId = '',
    this.hrQuery = '',
    this.joinImmediate = false,
    this.joinAfterMonths = false,
    this.jobType = 'All',
    this.dateRange,
    this.applicationStatus = '',
  });

  final String jobId;
  final String hrQuery;
  final bool joinImmediate;
  final bool joinAfterMonths;
  final String jobType;
  final DateTimeRange? dateRange;

  /// Normalized pending / shortlisted / rejected when used for applications; ignored for postings.
  final String applicationStatus;
}

/// Opens the shared recruitment filter drawer ([JobPostingFilterPanel]).
void openRecruitmentFilterSidePanel({
  required BuildContext context,
  required List<JobPosting> jobs,
  required RecruitmentFilterSelection initial,
  required bool showApplicationStatusFilter,
  required VoidCallback onReset,
  required void Function(RecruitmentFilterSelection applied) onApply,
}) {
  showRightSideTaskDetails(
    context,
    JobPostingFilterPanel(
      jobs: jobs,
      initialJobId: initial.jobId,
      initialHr: initial.hrQuery,
      initialJoinImmediate: initial.joinImmediate,
      initialJoinAfterMonths: initial.joinAfterMonths,
      initialJobType: initial.jobType,
      initialDateRange: initial.dateRange,
      showApplicationStatusFilter: showApplicationStatusFilter,
      initialApplicationStatus: initial.applicationStatus,
      onReset: onReset,
      onApply: ({
        required String jobId,
        required String hr,
        required bool joinImmediate,
        required bool joinAfterMonths,
        required String jobType,
        required DateTimeRange? dateRange,
        String applicationStatus = '',
      }) {
        onApply(
          RecruitmentFilterSelection(
            jobId: jobId,
            hrQuery: hr,
            joinImmediate: joinImmediate,
            joinAfterMonths: joinAfterMonths,
            jobType: jobType,
            dateRange: dateRange,
            applicationStatus: applicationStatus.trim(),
          ),
        );
      },
    ),
    widthFactor: 0.8,
    maxWidth: 420,
  );
}
