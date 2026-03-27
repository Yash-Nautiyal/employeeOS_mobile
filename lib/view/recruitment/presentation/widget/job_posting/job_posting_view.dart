import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, CustomTextButton, showRightSideTaskDetails;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/index.dart'
    show JobPostingMockDatasource, JobPostingModel;
import '../../pages/job_posting_section.dart';
import 'add_posting/add_job_posting_page.dart';
import 'components/filter/job_filter_panel.dart';
import 'components/filter/recruitment_list_filter_bar.dart';
import 'components/card/job_posting_card.dart';

class JobPostingView extends StatefulWidget {
  const JobPostingView({super.key});

  @override
  State<JobPostingView> createState() => _JobPostingViewState();
}

class _JobPostingViewState extends State<JobPostingView> {
  final scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final _mockDatasource = JobPostingMockDatasource.instance;
  late Future<List<JobPostingModel>> _jobsFuture;
  String _sortBy = 'Latest';

  // Filter state
  String _filterJobId = '';
  String _filterHr = '';
  bool _joinImmediate = false;
  bool _joinAfterMonths = false;
  String _jobType = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _mockDatasource.getAll();
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = _mockDatasource.getAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _openFilterPanel() {
    showRightSideTaskDetails(
      context,
      JobPostingFilterPanel(
        initialJobId: _filterJobId,
        initialHr: _filterHr,
        initialJoinImmediate: _joinImmediate,
        initialJoinAfterMonths: _joinAfterMonths,
        initialJobType: _jobType,
        initialDateRange: _dateRange,
        onReset: () {
          setState(() {
            _filterJobId = '';
            _filterHr = '';
            _joinImmediate = false;
            _joinAfterMonths = false;
            _jobType = 'All';
            _dateRange = null;
          });
        },
        onApply: ({
          required String jobId,
          required String hr,
          required bool joinImmediate,
          required bool joinAfterMonths,
          required String jobType,
          required DateTimeRange? dateRange,
        }) {
          setState(() {
            _filterJobId = jobId;
            _filterHr = hr;
            _joinImmediate = joinImmediate;
            _joinAfterMonths = joinAfterMonths;
            _jobType = jobType;
            _dateRange = dateRange;
          });
        },
      ),
      widthFactor: 0.8,
      maxWidth: 420,
    );
  }

  List<JobPostingModel> _applyFiltersAndSort(List<JobPostingModel> jobs) {
    final search = _searchController.text.trim().toLowerCase();
    var filtered = jobs.where((job) {
      if (search.isNotEmpty) {
        final hay = '${job.title} ${job.department} ${job.id}'.toLowerCase();
        if (!hay.contains(search)) return false;
      }

      if (_filterJobId.isNotEmpty && job.id != _filterJobId) {
        return false;
      }

      if (_filterHr.trim().isNotEmpty) {
        final hrNeedle = _filterHr.trim().toLowerCase();
        final hrHay = '${job.postedByName} ${job.postedByEmail}'.toLowerCase();
        if (!hrHay.contains(hrNeedle)) return false;
      }

      if (_joinImmediate || _joinAfterMonths) {
        final isImmediate = job.joiningType.toLowerCase() == 'immediate';
        final isAfterMonths = job.joiningType.toLowerCase() == 'notice period';
        final joinMatch = (_joinImmediate && isImmediate) ||
            (_joinAfterMonths && isAfterMonths);
        if (!joinMatch) return false;
      }

      if (_jobType != 'All') {
        if (_jobType == 'Internship' && !job.isInternship) return false;
        if (_jobType == 'Full-time' && job.isInternship) return false;
      }

      if (_dateRange != null) {
        final d = job.createdAt ?? job.lastDateToApply;
        if (d == null) return false;
        final inRange =
            !d.isBefore(_dateRange!.start) && !d.isAfter(_dateRange!.end);
        if (!inRange) return false;
      }
      return true;
    }).toList();

    if (_sortBy == 'Latest') {
      filtered.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    } else if (_sortBy == 'Oldest') {
      filtered.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<AuthBloc>().state.currentProfile;
    final canManageJobs = profile?.canManageOwnJobs ?? false;

    return SingleChildScrollView(
      controller: scrollController,
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Flexible(
                    child: CustomBreadCrumbs(
                      theme: theme,
                      heading: 'Job Posting',
                      routes: const ['Dashboard', 'Job', 'Posting'],
                    ),
                  ),
                  if (canManageJobs)
                    CustomTextButton(
                      backgroundColor: theme.colorScheme.tertiary,
                      padding: 0,
                      onClick: () async {
                        final shouldRefresh =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => const AddJobPostingPage(),
                          ),
                        );
                        if (!mounted) return;
                        if (shouldRefresh == true) _refreshJobs();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/common/solid/ic-solar-case-round-bold.svg',
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              theme.scaffoldBackgroundColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Add Posting',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.scaffoldBackgroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RecruitmentListFilterBar(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
            onFiltersTap: _openFilterPanel,
            sortBy: _sortBy,
            onSortChanged: (v) => setState(() => _sortBy = v),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<JobPostingModel>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final jobs = _applyFiltersAndSort(snapshot.data!);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final useGrid = width >= 720;

                      Widget buildCard(JobPostingModel job) {
                        final canEditAndDelete = profile != null &&
                            (profile.canManageAnyJob ||
                                (profile.canManageOwnJobs &&
                                    job.postedByEmail == profile.email));
                        return JobPostingCard(
                          theme: theme,
                          job: job,
                          canEditAndDelete: canEditAndDelete,
                          onJobActiveChanged: (jobId, isActive) async {
                            _mockDatasource.setJobActive(jobId, isActive);
                            if (mounted) _refreshJobs();
                          },
                          onViewTap: () {
                            Navigator.of(context).pushNamed(
                              JobPostingSection.routeJobView,
                              arguments: {'id': job.id},
                            );
                          },
                          onEditTap: () async {
                            await Navigator.of(context).pushNamed(
                              JobPostingSection.routeJobEdit,
                              arguments: {'job': job},
                            );
                            if (mounted) _refreshJobs();
                          },
                        );
                      }

                      if (!useGrid) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: jobs.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: buildCard(jobs[index]),
                          ),
                        );
                      }

                      // Responsive grid across tablet and desktop widths.
                      final crossAxisCount = (width / 340).floor().clamp(2, 5);
                      const spacing = 12.0;
                      final cardWidth =
                          (width - ((crossAxisCount - 1) * spacing)) /
                              crossAxisCount;
                      final aspectRatio =
                          (cardWidth / 360).clamp(0.75, 1.15).toDouble();

                      return GridView.builder(
                        controller: scrollController,
                        itemCount: jobs.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) => buildCard(jobs[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
