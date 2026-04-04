import 'dart:async';

import 'package:employeeos/core/common/components/custom_toast.dart';
import 'package:employeeos/core/common/components/empty_content.dart';
import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, CustomTextButton;
import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import 'package:toastification/toastification.dart';
import '../bloc/job_application/job_application_bloc.dart';
import 'package:employeeos/view/recruitment/presentation/widget/index.dart'
    show JobApplicationCard;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/filter/logic/job_application_filter_logic.dart';
import '../utils/job_applications_list_query_mapper.dart';
import '../utils/filter/ui/recruitment_filter_side_panel.dart';
import '../widget/injection/job_posting_injection.dart';
import '../widget/job_application/job_application_injection.dart'
    show JobApplicationInjection;
import '../widget/job_application/job_applications_pagination_bar.dart';
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

  Timer? _searchDebounce;

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

  void _dispatchListFetch({int page = 1}) {
    _bloc.add(
      JobApplicationsListFetchRequested(
        listQueryFromFilterCriteria(_filterCriteria, page: page),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bloc = JobApplicationInjection.createBloc();
    _dispatchListFetch(page: 1);
    _loadJobsForFilter();
  }

  Future<void> _loadJobsForFilter() async {
    try {
      final jobs = await JobPostingInjection.getAllJobs();
      if (!mounted) return;
      setState(() => _jobsForFilter = jobs);
    } on RemoteDataException {
      if (!mounted) return;
      setState(() => _jobsForFilter = []);
    } catch (_) {
      if (!mounted) return;
      setState(() => _jobsForFilter = []);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openFilterPanel() {
    openRecruitmentFilterSidePanel(
      context: context,
      jobs: _jobsForFilter,
      initial: RecruitmentFilterSelection(
        jobId: _filterJobId,
        hrQuery: _filterHr,
        joinImmediate: _joinImmediate,
        joinAfterMonths: _joinAfterMonths,
        jobType: _jobType,
        dateRange: _dateRange,
        applicationStatus: _filterApplicationStatus,
      ),
      showApplicationStatusFilter: true,
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
        _dispatchListFetch(page: 1);
      },
      onApply: (s) {
        setState(() {
          _filterJobId = s.jobId;
          _filterHr = s.hrQuery;
          _joinImmediate = s.joinImmediate;
          _joinAfterMonths = s.joinAfterMonths;
          _jobType = s.jobType;
          _dateRange = s.dateRange;
          _filterApplicationStatus = s.applicationStatus;
        });
        _dispatchListFetch(page: 1);
      },
    );
  }

  void _onSearchChanged() {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _dispatchListFetch(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<JobApplicationBloc, JobApplicationState>(
        listenWhen: (prev, curr) => curr is JobApplicationListenState,
        listener: (context, state) {
          if (state is JobApplicationError) {
            showCustomToast(
              context: context,
              type: ToastificationType.error,
              title: 'Error',
              description: state.message,
            );
          }
        },
        child: BlocListener<JobApplicationBloc, JobApplicationState>(
          listenWhen: (prev, curr) {
            if (curr is! JobApplicationsLoaded) return false;
            if (prev is! JobApplicationsLoaded) return true;
            return prev.query.page != curr.query.page && !curr.isLoadingPage;
          },
          listener: (context, state) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          },
          child: BlocBuilder<JobApplicationBloc, JobApplicationState>(
            buildWhen: (previous, current) =>
                current is! JobApplicationListenState,
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
                              routes: const [
                                'Dashboard',
                                'Job',
                                'Applications'
                              ],
                            ),
                            const SizedBox(height: 20),
                            RecruitmentListFilterBar(
                              searchController: _searchController,
                              onSearchChanged: (_) => _onSearchChanged(),
                              onFiltersTap: _openFilterPanel,
                              sortBy: _sortBy,
                              onSortChanged: (v) {
                                setState(() => _sortBy = v);
                                _dispatchListFetch(page: 1);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total applications:',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    switch (state) {
                                      JobApplicationsLoaded(
                                        :final totalCount
                                      ) =>
                                        ' $totalCount',
                                      JobApplicationLoading() ||
                                      JobApplicationInitial() =>
                                        ' …',
                                      JobApplicationFetchError() => ' —',
                                      JobApplicationError() => ' …',
                                    },
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
        ),
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
    if (state is JobApplicationFetchError) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyContent(
              icon: 'assets/icons/empty/ic-folder-empty.svg',
              title: 'Failed to load applications',
            ),
            const SizedBox(height: 12),
            CustomTextButton(
              onClick: () => _dispatchListFetch(page: 1),
              backgroundColor: theme.colorScheme.tertiary,
              padding: 1,
              child: Text('Retry',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.scaffoldBackgroundColor,
                  )),
            ),
          ],
        ),
      );
    }
    if (state is JobApplicationsLoaded) {
      final apps = state.applications;
      final totalPages = state.totalPages;

      if (state.totalCount == 0) {
        final hasFilters = _searchController.text.trim().isNotEmpty ||
            _filterJobId.isNotEmpty ||
            _filterHr.trim().isNotEmpty ||
            _joinImmediate ||
            _joinAfterMonths ||
            _jobType != 'All' ||
            _filterApplicationStatus.isNotEmpty ||
            _dateRange != null;
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              hasFilters
                  ? 'No applications match your search or filters.'
                  : 'No applications yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }

      if (apps.isEmpty && !state.isLoadingPage) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No applications on this page.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }

      return SliverMainAxisGroup(
        slivers: [
          SliverSafeArea(
            top: false,
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = MediaQuery.of(context).size.width;
                final useGrid = width >= 720;
                final crossAxisCount = (width / 340).floor().clamp(2, 5);
                if (useGrid) {
                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return JobApplicationCard(
                        theme: theme,
                        application: app,
                        onShortlist: () =>
                            context.read<JobApplicationBloc>().add(
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
                      final app = apps[index];
                      return JobApplicationCard(
                        theme: theme,
                        application: app,
                        onShortlist: () =>
                            context.read<JobApplicationBloc>().add(
                                  JobApplicationShortlistRequested(app.id),
                                ),
                        onReject: () => context.read<JobApplicationBloc>().add(
                              JobApplicationRejectRequested(app.id),
                            ),
                      );
                    },
                    childCount: apps.length,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: JobApplicationsPaginationBar(
              currentPage: state.query.page,
              totalPages: totalPages,
              isLoading: state.isLoadingPage,
              onPageSelected: (page) {
                context
                    .read<JobApplicationBloc>()
                    .add(JobApplicationsPageSelected(page));
              },
            ),
          ),
        ],
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
