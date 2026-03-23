import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, fmtDate, fmtTime, showRightSideTaskDetails;
import 'package:employeeos/view/recruitment/data/index.dart'
    show JobPostingMockDatasource, JobPostingModel, jobApplicationMockList;
import 'package:employeeos/view/recruitment/index.dart' show JobApplicationCard;
import 'package:employeeos/view/recruitment/presentation/index.dart'
    show RecruitmentListFilterBar;
import 'package:employeeos/view/recruitment/presentation/widget/common/filter/job_filter_panel.dart';
import 'package:flutter/material.dart';

class JobApplicationView extends StatefulWidget {
  const JobApplicationView({super.key});

  @override
  State<JobApplicationView> createState() => _JobApplicationViewState();
}

class _JobApplicationViewState extends State<JobApplicationView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _datasource = JobPostingMockDatasource.instance;
  late Future<List<JobPostingModel>> _jobsFuture;

  bool _compactMode = false;
  String _sortBy = 'Latest';

  // Same panel fields as job posting; applied to applications via linked job + applied_on.
  String _filterJobId = '';
  String _filterHr = '';
  bool _joinImmediate = false;
  bool _joinAfterMonths = false;
  String _jobType = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _datasource.getAll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  JobPostingModel? _jobFor(
    String jobId,
    List<JobPostingModel> jobs,
  ) {
    try {
      return jobs.firstWhere((j) => j.id == jobId);
    } catch (_) {
      return null;
    }
  }

  String _jobTitleFor(String jobId, List<JobPostingModel> jobs) {
    final j = _jobFor(jobId, jobs);
    return j?.title ?? 'Unknown Job';
  }

  List<Map<String, dynamic>> _applyFiltersAndSortApplications(
    List<Map<String, dynamic>> apps,
    List<JobPostingModel> jobs,
  ) {
    final search = _searchController.text.trim().toLowerCase();

    var filtered = apps.where((app) {
      final jobId = app['job_id']?.toString() ?? '';
      final job = _jobFor(jobId, jobs);

      if (search.isNotEmpty) {
        final title = job?.title ?? '';
        final hay =
            '${app['full_name']} ${app['email']} ${app['phone']} $title $jobId'
                .toLowerCase();
        if (!hay.contains(search)) return false;
      }

      if (_filterJobId.isNotEmpty && jobId != _filterJobId) {
        return false;
      }

      if (_filterHr.trim().isNotEmpty) {
        if (job == null) return false;
        final hrNeedle = _filterHr.trim().toLowerCase();
        final hrHay = '${job.postedByName} ${job.postedByEmail}'.toLowerCase();
        if (!hrHay.contains(hrNeedle)) return false;
      }

      if (_joinImmediate || _joinAfterMonths) {
        if (job == null) return false;
        final isImmediate = job.joiningType.toLowerCase() == 'immediate';
        final isAfterMonths = job.joiningType.toLowerCase() == 'notice period';
        final joinMatch = (_joinImmediate && isImmediate) ||
            (_joinAfterMonths && isAfterMonths);
        if (!joinMatch) return false;
      }

      if (_jobType != 'All') {
        if (job == null) return false;
        if (_jobType == 'Internship' && !job.isInternship) return false;
        if (_jobType == 'Full-time' && job.isInternship) return false;
      }

      if (_dateRange != null) {
        final applied = DateTime.tryParse(app['applied_on']?.toString() ?? '');
        if (applied == null) return false;
        final ad = DateTime(applied.year, applied.month, applied.day);
        final rs = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final re = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
        );
        if (ad.isBefore(rs) || ad.isAfter(re)) return false;
      }

      return true;
    }).toList();

    if (_sortBy == 'Latest') {
      filtered.sort((a, b) {
        final ad = DateTime.tryParse(a['applied_on']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd = DateTime.tryParse(b['applied_on']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    } else if (_sortBy == 'Oldest') {
      filtered.sort((a, b) {
        final ad = DateTime.tryParse(a['applied_on']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd = DateTime.tryParse(b['applied_on']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBreadCrumbs(
            theme: theme,
            heading: 'Job Applications',
            routes: const ['Dashboard', 'Job', 'Applications'],
          ),
          const SizedBox(
            height: 25,
          ),
          RecruitmentListFilterBar(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
            onFiltersTap: _openFilterPanel,
            sortBy: _sortBy,
            onSortChanged: (v) => setState(() => _sortBy = v),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 12),
            child: FutureBuilder<List<JobPostingModel>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                final jobs = snapshot.data ?? const <JobPostingModel>[];
                final applications = _applyFiltersAndSortApplications(
                  List<Map<String, dynamic>>.from(jobApplicationMockList),
                  jobs,
                );
                return Row(
                  children: [
                    Text(
                      '${applications.length} applications',
                      style: tt.bodySmall?.copyWith(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Compact',
                      style: tt.bodySmall?.copyWith(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.65,
                      child: Switch(
                        value: _compactMode,
                        onChanged: (v) => setState(() => _compactMode = v),
                        activeTrackColor: theme.colorScheme.primary,
                        activeColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<List<JobPostingModel>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final jobs = snapshot.data!;
                final applications = _applyFiltersAndSortApplications(
                  List<Map<String, dynamic>>.from(jobApplicationMockList),
                  jobs,
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final useGrid = width >= 600;
                    const spacing = 12.0;

                    Widget buildItem(Map<String, dynamic> app) {
                      final appliedOn = DateTime.tryParse(
                        app['applied_on']?.toString() ?? '',
                      );
                      final appliedOnText = appliedOn != null
                          ? '${fmtDate(appliedOn)} ${fmtTime(appliedOn)}'
                          : '-';
                      return JobApplicationCard(
                        theme: theme,
                        applicationId: app['id']?.toString() ?? '-',
                        candidateName: app['full_name']?.toString() ?? '-',
                        jobTitle: _jobTitleFor(
                          app['job_id']?.toString() ?? '',
                          jobs,
                        ),
                        phone: app['phone']?.toString() ?? '-',
                        email: app['email']?.toString() ?? '-',
                        appliedOnText: appliedOnText,
                        status: app['status']?.toString() ?? 'Applied',
                        resumeUrl: app['resume_url']?.toString() ?? '',
                        compact: _compactMode,
                      );
                    }

                    if (!useGrid) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: applications.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) => buildItem(applications[i]),
                      );
                    }

                    final crossAxisCount = _compactMode
                        ? (width / 280).floor().clamp(2, 4)
                        : (width / 320).floor().clamp(2, 3);

                    final mainAxisExtent = _compactMode ? 70.0 : 266.0;

                    return GridView.builder(
                      controller: _scrollController,
                      itemCount: applications.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: spacing,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (_, i) => buildItem(applications[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
