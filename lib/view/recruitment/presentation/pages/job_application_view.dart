import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, showRightSideTaskDetails;
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import '../bloc/job_application/job_application_bloc.dart';
import 'package:employeeos/view/recruitment/presentation/widget/index.dart'
    show JobApplicationCard;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/job_application_filter_logic.dart';
import '../widget/injection/job_posting_injection.dart';
import '../widget/job_application/job_application_injection.dart'
    show JobApplicationInjection;
import '../widget/job_posting/components/filter/job_filter_panel.dart';
import '../widget/job_posting/components/filter/recruitment_list_filter_bar.dart';

class JobApplicationView extends StatefulWidget {
  const JobApplicationView({super.key});

  @override
  State<JobApplicationView> createState() => _JobApplicationViewState();
}

class _JobApplicationViewState extends State<JobApplicationView> {
  late final ScrollController _scrollController;
  late final JobApplicationBloc _bloc;

  final _searchController = TextEditingController();

  String _sortBy = 'Latest';

  String _filterJobId = '';
  String _filterHr = '';
  bool _joinImmediate = false;
  bool _joinAfterMonths = false;
  String _jobType = 'All';
  String _filterApplicationStatus = '';
  DateTimeRange? _dateRange;

  List<JobPosting> _jobsForFilter = const [];

  JobApplicationFilterCriteria get _filterCriteria =>
      JobApplicationFilterCriteria(
        searchQuery: _searchController.text,
        jobId: _filterJobId,
        hrQuery: _filterHr,
        joinImmediate: _joinImmediate,
        joinAfterMonths: _joinAfterMonths,
        jobType: _jobType,
        applicationStatus: _filterApplicationStatus,
        dateRange: _dateRange,
        sortBy: _sortBy,
      );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bloc = JobApplicationInjection.createBloc();
    _bloc.add(const JobApplicationsLoadRequested());
    JobPostingInjection.getAllJobs().then((jobs) {
      if (!mounted) return;
      setState(() => _jobsForFilter = jobs);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openFilterPanel() {
    showRightSideTaskDetails(
      context,
      JobPostingFilterPanel(
        jobs: _jobsForFilter,
        initialJobId: _filterJobId,
        initialHr: _filterHr,
        initialJoinImmediate: _joinImmediate,
        initialJoinAfterMonths: _joinAfterMonths,
        initialJobType: _jobType,
        initialDateRange: _dateRange,
        showApplicationStatusFilter: true,
        initialApplicationStatus: _filterApplicationStatus,
        onReset: () {
          setState(() {
            _filterJobId = '';
            _filterHr = '';
            _joinImmediate = false;
            _joinAfterMonths = false;
            _jobType = 'All';
            _filterApplicationStatus = '';
            _dateRange = null;
          });
          _bloc.add(const JobApplicationsLoadRequested());
        },
        onApply: ({
          required String jobId,
          required String hr,
          required bool joinImmediate,
          required bool joinAfterMonths,
          required String jobType,
          required DateTimeRange? dateRange,
          String applicationStatus = '',
        }) {
          setState(() {
            _filterJobId = jobId;
            _filterHr = hr;
            _joinImmediate = joinImmediate;
            _joinAfterMonths = joinAfterMonths;
            _jobType = jobType;
            _dateRange = dateRange;
            _filterApplicationStatus = applicationStatus.trim();
          });
          _bloc.add(
            JobApplicationsLoadRequested(
              jobId: jobId.trim().isEmpty ? null : jobId.trim(),
            ),
          );
        },
      ),
      widthFactor: 0.8,
      maxWidth: 420,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<JobApplicationBloc, JobApplicationState>(
        builder: (context, state) {
          return Scrollbar(
            controller: _scrollController,
            thickness: 5,
            trackVisibility: true,
            interactive: true,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 20,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomBreadCrumbs(
                          theme: theme,
                          heading: 'Job Applications',
                          routes: const ['Dashboard', 'Job', 'Applications'],
                        ),
                        const SizedBox(height: 20),
                        RecruitmentListFilterBar(
                          searchController: _searchController,
                          onSearchChanged: (_) => setState(() {}),
                          onFiltersTap: _openFilterPanel,
                          sortBy: _sortBy,
                          onSortChanged: (v) => setState(() => _sortBy = v),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildSliverBody(context, theme, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverBody(
    BuildContext context,
    ThemeData theme,
    JobApplicationState state,
  ) {
    if (state is JobApplicationLoading || state is JobApplicationInitial) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state is JobApplicationError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.message),
        ),
      );
    }
    if (state is JobApplicationsLoaded) {
      final filtered = applyJobApplicationFiltersAndSort(
        state.applications,
        _filterCriteria,
        _jobsForFilter,
      );
      if (state.applications.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No applications yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }
      if (filtered.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No applications match your search or filters.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }
      return SliverSafeArea(
        top: false,
        sliver: SliverLayoutBuilder(builder: (context, constraints) {
          final width = MediaQuery.of(context).size.width;
          final useGrid = width >= 720;
          final crossAxisCount = (width / 340).floor().clamp(2, 5);
          if (useGrid) {
            return SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final app = filtered[index];
                return JobApplicationCard(
                  theme: theme,
                  application: app,
                  onShortlist: () => context.read<JobApplicationBloc>().add(
                        JobApplicationShortlistRequested(app.id),
                      ),
                  onReject: () => context.read<JobApplicationBloc>().add(
                        JobApplicationRejectRequested(app.id),
                      ),
                );
              },
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final app = filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: JobApplicationCard(
                    theme: theme,
                    application: app,
                    onShortlist: () => context.read<JobApplicationBloc>().add(
                          JobApplicationShortlistRequested(app.id),
                        ),
                    onReject: () => context.read<JobApplicationBloc>().add(
                          JobApplicationRejectRequested(app.id),
                        ),
                  ),
                );
              },
              childCount: filtered.length,
            ),
          );
        }),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
