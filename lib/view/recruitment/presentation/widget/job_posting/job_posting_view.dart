import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/common/components/ui/custom_toast.dart';
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/core/user/current_user_profile.dart';
import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, CustomTextButton;
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import 'package:employeeos/view/recruitment/presentation/bloc/job_posting/job_posting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

import '../../utils/filter/logic/job_posting_filter_logic.dart';
import '../../utils/filter/ui/recruitment_filter_side_panel.dart';
import 'components/card/job_posting_card_slot.dart';
import 'components/filter/recruitment_list_filter_bar.dart';

class JobPostingView extends StatefulWidget {
  const JobPostingView({super.key});

  @override
  State<JobPostingView> createState() => _JobPostingViewState();
}

class _JobPostingViewState extends State<JobPostingView> {
  final scrollController = ScrollController();
  final _searchController = TextEditingController();

  String _sortBy = 'Latest';

  String _filterJobId = '';
  String _filterHr = '';
  bool _joinImmediate = false;
  bool _joinAfterMonths = false;
  String _jobType = 'All';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _refreshJobPostings() {
    context.read<JobPostingBloc>().add(const RefreshJobPostingsEvent());
  }

  void _openFilterPanel() {
    openRecruitmentFilterSidePanel(
      context: context,
      jobs: _currentJobsFromBloc(),
      initial: RecruitmentFilterSelection(
        jobId: _filterJobId,
        hrQuery: _filterHr,
        joinImmediate: _joinImmediate,
        joinAfterMonths: _joinAfterMonths,
        jobType: _jobType,
        dateRange: _dateRange,
      ),
      showApplicationStatusFilter: false,
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
      onApply: (s) {
        setState(() {
          _filterJobId = s.jobId;
          _filterHr = s.hrQuery;
          _joinImmediate = s.joinImmediate;
          _joinAfterMonths = s.joinAfterMonths;
          _jobType = s.jobType;
          _dateRange = s.dateRange;
        });
      },
    );
  }

  List<JobPosting> _currentJobsFromBloc() {
    final s = context.read<JobPostingBloc>().state;
    if (s is JobPostingLoaded) return s.jobs;
    return const [];
  }

  JobPostingFilterCriteria get _filterCriteria {
    return JobPostingFilterCriteria(
      searchQuery: _searchController.text,
      jobId: _filterJobId,
      hrQuery: _filterHr,
      joinImmediate: _joinImmediate,
      joinAfterMonths: _joinAfterMonths,
      jobType: _jobType,
      dateRange: _dateRange,
      sortBy: _sortBy,
    );
  }

  Future<void> _onSetJobActive(String jobId, bool isActive) async {
    context.read<JobPostingBloc>().add(
          SetJobActiveEvent(jobId: jobId, isActive: isActive),
        );
  }

  Future<void> _onCloseJob(String jobId) async {
    context.read<JobPostingBloc>().add(CloseJobEvent(jobId));
  }

  Future<void> _onDeleteJob(String jobId) async {
    context.read<JobPostingBloc>().add(DeleteJobEvent(jobId));
  }

  void _onViewJob(String jobId) {
    AppRecruitmentJobPostingDetailRoute(jobId: jobId).push(context);
  }

  Future<void> _onEditJob(JobPosting job) async {
    final updated = await AppRecruitmentJobPostingEditRoute(
      jobId: job.id,
      $extra: job,
    ).push<bool>(context);
    if (updated == true) {
      _refreshJobPostings();
    }
  }

  Future<void> _onAddPosting() async {
    final created =
        await const AppRecruitmentJobPostingAddRoute().push<bool>(context);
    if (created == true) {
      _refreshJobPostings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<AuthBloc>().state.currentProfile;

    return BlocListener<JobPostingBloc, JobPostingState>(
      listenWhen: (previous, current) =>
          current is JobPostingLoaded && current.transientError != null,
      listener: (context, state) {
        final loaded = state as JobPostingLoaded;
        final msg = loaded.transientError;
        if (msg == null) return;
        showCustomToast(
            context: context,
            type: ToastificationType.error,
            title: 'Error',
            description: msg);
        context.read<JobPostingBloc>().add(const ClearTransientErrorEvent());
      },
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 5,
          bottom: 20,
        ),
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
                    if (profile?.canManageOwnJobs ?? false)
                      CustomTextButton(
                        backgroundColor: theme.colorScheme.tertiary,
                        padding: 0,
                        onClick: _onAddPosting,
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
            const SizedBox(height: 20),
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
                child: _JobPostingFeedBody(
                  theme: theme,
                  profile: profile,
                  scrollController: scrollController,
                  criteria: _filterCriteria,
                  onSetJobActive: _onSetJobActive,
                  onCloseJob: _onCloseJob,
                  onDeleteJob: _onDeleteJob,
                  onViewJob: _onViewJob,
                  onEditJob: _onEditJob,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPostingFeedBody extends StatelessWidget {
  const _JobPostingFeedBody({
    required this.theme,
    required this.profile,
    required this.scrollController,
    required this.criteria,
    required this.onSetJobActive,
    required this.onCloseJob,
    required this.onDeleteJob,
    required this.onViewJob,
    required this.onEditJob,
  });

  final ThemeData theme;
  final CurrentUserProfile? profile;
  final ScrollController scrollController;
  final JobPostingFilterCriteria criteria;

  final Future<void> Function(String jobId, bool isActive) onSetJobActive;
  final Future<void> Function(String jobId) onCloseJob;
  final Future<void> Function(String jobId) onDeleteJob;
  final void Function(String jobId) onViewJob;
  final Future<void> Function(JobPosting job) onEditJob;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<JobPostingBloc, JobPostingState, int>(
      selector: (state) {
        if (state is JobPostingLoaded) return 2;
        if (state is JobPostingLoadError) return 1;
        return 0;
      },
      builder: (context, mode) {
        if (mode == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (mode == 1) {
          return BlocSelector<JobPostingBloc, JobPostingState, String>(
            selector: (s) => s is JobPostingLoadError ? s.message : '',
            builder: (context, message) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message.isEmpty ? 'Failed to load jobs.' : message,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        }
        return BlocSelector<JobPostingBloc, JobPostingState, List<JobPosting>?>(
          selector: (state) {
            if (state is! JobPostingLoaded) return null;
            return state.jobs;
          },
          builder: (context, allJobs) {
            if (allJobs == null) return const SizedBox.shrink();
            final jobs = applyJobPostingFiltersAndSort(allJobs, criteria);
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final useGrid = width >= 720;

                Widget slotFor(int index) {
                  final job = jobs[index];
                  return JobPostingCardSlot(
                    key: ValueKey<String>(job.id),
                    jobId: job.id,
                    theme: theme,
                    profile: profile,
                    onViewTap: () => onViewJob(job.id),
                    onEditTap: () => onEditJob(job),
                    onJobActiveChanged: onSetJobActive,
                    onCloseJob: onCloseJob,
                    onDeleteJob: onDeleteJob,
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
                      child: slotFor(index),
                    ),
                  );
                }

                final crossAxisCount = (width / 340).floor().clamp(2, 5);
                const spacing = 12.0;
                final cardWidth =
                    (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
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
                  itemBuilder: (context, index) => slotFor(index),
                );
              },
            );
          },
        );
      },
    );
  }
}
