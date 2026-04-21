import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/common/components/ui/custom_title_header.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_bloc.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_event.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_state.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_filters.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_chart.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_pipelines.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_container.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HiringView extends StatefulWidget {
  const HiringView({super.key});

  @override
  State<HiringView> createState() => _HiringViewState();
}

class _HiringViewState extends State<HiringView> {
  final _postingDateFromController = TextEditingController();
  final _postingDateToController = TextEditingController();
  final _lastDateFromController = TextEditingController();
  final _lastDateToController = TextEditingController();

  late PageController _pageController;
  int _currentPage = 0;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _postingDateFromController.dispose();
    _postingDateToController.dispose();
    _lastDateFromController.dispose();
    _lastDateToController.dispose();
    _pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HiringBloc>();
    final done = bloc.stream.firstWhere(
      (s) =>
          s.status == HiringStatus.success ||
          s.status == HiringStatus.failure,
    );
    bloc.add(const HiringRefreshRequested());
    await done;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final profile = authState is Authenticated ? authState.profile : null;
    final showHrFilter = profile?.isAdmin ?? false;

    return BlocBuilder<HiringBloc, HiringState>(
      builder: (context, state) {
        if (state.status == HiringStatus.loading && !state.hasCompletedLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == HiringStatus.loading && state.hasCompletedLoad)
              const LinearProgressIndicator(minHeight: 2),
            if (state.status == HiringStatus.failure &&
                state.errorMessage != null)
              Material(
                color:
                    theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context
                            .read<HiringBloc>()
                            .add(const HiringLoadRequested()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(
                            top: MediaQuery.of(context).padding.top + 10,
                            bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HiringFilters(
                          theme: theme,
                          appliedFilters: state.filters,
                          jobOptions: state.jobOptions,
                          hrOptions: state.hrOptions,
                          showHrFilter: showHrFilter,
                          postingDateFromController: _postingDateFromController,
                          postingDateToController: _postingDateToController,
                          lastDateFromController: _lastDateFromController,
                          lastDateToController: _lastDateToController,
                        ),
                        const SizedBox(height: 10),
                        _buildStatsSection(
                          theme,
                          MediaQuery.of(context).size.height,
                          state.dashboard.summary,
                        ),
                        const SizedBox(height: 20),
                        _buildResponsiveChartsSection(
                          theme,
                          state.dashboard.pipelineOverview,
                          state.dashboard.positionsByJob,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              CustomTitleHeader(
                                theme: theme,
                                title: 'Job-wise Hiring Pipeline',
                                subtitle:
                                    'Detailed pipeline status for each job posting',
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: HiringJobPipelines(
                                  scrollController: scrollController,
                                  theme: theme,
                                  data: state.allJobPipelines,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveChartsSection(
    ThemeData theme,
    PipelineOverview pipelineOverview,
    List<JobPositionData> chartData,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final shouldUseSideBySideLayout = !isPortrait || screenWidth > 600;

    if (!shouldUseSideBySideLayout) {
      return Column(
        children: [
          SizedBox(
            height: 440,
            child: PageView(
              padEnds: false,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                HiringJobChart(theme: theme, data: chartData),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CustomTitleHeader(
                        theme: theme,
                        title: 'Hiring Pipeline Overview',
                        subtitle: 'Track application and interview progress',
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: HiringPipelineContainer(
                          theme: theme,
                          big: true,
                          data: pipelineOverview,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 440,
      child: Row(
        children: [
          Expanded(
            flex: screenWidth > 800 ? 1 : 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: HiringJobChart(theme: theme, data: chartData),
            ),
          ),
          Expanded(
            flex: screenWidth > 800 ? 1 : 3,
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CustomTitleHeader(
                    theme: theme,
                    title: 'Hiring Pipeline Overview',
                    subtitle: 'Track application and interview progress',
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: HiringPipelineContainer(
                      theme: theme,
                      big: true,
                      data: pipelineOverview,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    ThemeData theme,
    double screenHeight,
    HiringSummary summary,
  ) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final data = [
      {
        'title': 'Total Applications',
        'value': '${summary.totalApplications}',
        'valueColor': AppPallete.grey600,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-clipboard.svg',
      },
      {
        'title': 'Total Shortlisted',
        'value': '${summary.totalShortlisted}',
        'valueColor': AppPallete.primaryMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-mingcute-target.svg',
      },
      {
        'title': 'Total Rejected',
        'value': '${summary.totalRejected}',
        'valueColor': AppPallete.errorMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-shield-warning.svg',
      },
      {
        'title': 'Pending',
        'value': '${summary.totalPending}',
        'valueColor': AppPallete.warningMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-alert.svg',
      },
      {
        'title': 'Jobs',
        'value': '${summary.totalJobs}',
        'valueColor': AppPallete.successMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-case.svg',
      },
      {
        'title': 'Positions',
        'value': '${summary.totalPositions}',
        'valueColor': AppPallete.infoMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-user.svg',
      },
    ];
    return HiringStatsCard(data: data);
  }
}
