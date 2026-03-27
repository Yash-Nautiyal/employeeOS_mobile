import 'package:employeeos/core/common/components/empty_content.dart';
import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, showRightSideTaskDetails;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/index.dart'
    show InterviewSchedulingLocalDataSource, InterviewSchedulingRepositoryImpl;
import '../../domain/index.dart' show GetInterviewCandidatesUseCase;
import '../../domain/interview_scheduling/entities/interview_enums.dart';
import '../bloc/interview_scheduling/interview_scheduling_bloc.dart';
import '../widget/index.dart'
    show
        ActionHeader,
        CandidateTabs,
        CandidatesTable,
        InterviewFilterPanel,
        InterviewRoundsTab;
import '../widget/interview_scheduling/table/interview_table_action_tools.dart';

class InterviewSchedulingView extends StatefulWidget {
  const InterviewSchedulingView({super.key});

  @override
  State<InterviewSchedulingView> createState() =>
      _InterviewSchedulingViewState();
}

class _InterviewSchedulingViewState extends State<InterviewSchedulingView>
    with TickerProviderStateMixin {
  late final TabController _roundTabController;
  late final TabController _candidateTabController;
  late final TextEditingController _searchController;
  late final InterviewSchedulingBloc _bloc;

  @override
  void initState() {
    super.initState();
    final repository = InterviewSchedulingRepositoryImpl(
      InterviewSchedulingLocalDataSource.instance,
    );
    _bloc = InterviewSchedulingBloc(
      getInterviewCandidatesUseCase: GetInterviewCandidatesUseCase(repository),
      repository: repository,
    );

    _roundTabController = TabController(
      length: InterviewRound.values.length,
      vsync: this,
      initialIndex: InterviewRound.telephone.index,
    );
    _candidateTabController = TabController(
      length: InterviewCandidateTab.values.length,
      vsync: this,
    );
    _searchController = TextEditingController();

    _candidateTabController.addListener(() {
      if (_candidateTabController.indexIsChanging) return;
      _bloc.add(
        InterviewTabChanged(
          InterviewCandidateTab.values[_candidateTabController.index],
        ),
      );
    });

    _roundTabController.addListener(() {
      if (_roundTabController.indexIsChanging) return;
      _bloc.add(
        InterviewRoundChanged(
          InterviewRound.values[_roundTabController.index],
        ),
      );
    });

    _bloc.add(InterviewSchedulingStarted());
  }

  @override
  void dispose() {
    _roundTabController.dispose();
    _candidateTabController.dispose();
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || screenWidth > 700;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<InterviewSchedulingBloc, InterviewSchedulingState>(
        listenWhen: (previous, current) =>
            previous.activeTab != current.activeTab ||
            previous.activeRound != current.activeRound,
        listener: (context, state) {
          if (state.activeRound.usesEligibleScheduledTabs &&
              _candidateTabController.index != state.activeTab.index) {
            _candidateTabController.animateTo(state.activeTab.index);
          }
          if (_roundTabController.index != state.activeRound.index) {
            _roundTabController.animateTo(state.activeRound.index);
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 20,
            ),
            child: Column(
              children: [
                CustomBreadCrumbs(
                  theme: theme,
                  heading: 'Interview Scheduling',
                  routes: const [
                    'Dashboard',
                    'Recruitment',
                    'Interview Scheduling'
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActionHeader(
                        theme: theme,
                        isWideScreen: isWideScreen,
                        searchController: _searchController,
                        onFilterTap: () =>
                            _openFilterPanel(context, theme, state),
                        onSearchChanged: (value) => _bloc.add(
                          InterviewSearchChanged(value),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InterviewRoundsTab(
                        theme: theme,
                        isWideScreen: isWideScreen,
                        controller: _roundTabController,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.shadowColor),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor,
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (state.activeRound.usesEligibleScheduledTabs)
                              Row(
                                children: [
                                  Expanded(
                                    child: CandidateTabs(
                                      theme: theme,
                                      controller: _candidateTabController,
                                    ),
                                  ),
                                ],
                              ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: state.filteredCandidates.isNotEmpty
                                  ? ClipRRect(
                                      key: const ValueKey('table'),
                                      borderRadius: state.activeRound
                                              .usesEligibleScheduledTabs
                                          ? BorderRadius.zero
                                          : BorderRadius.circular(12),
                                      child: CandidatesTable(
                                        screenWidth: screenWidth,
                                        candidates: state.filteredCandidates,
                                        selectedIds: state.selectedIds,
                                        showRejectedRoundColumn:
                                            state.activeRound ==
                                                InterviewRound.rejected,
                                        actionToolbar:
                                            InterviewTableActionTools(
                                          theme: theme,
                                          state: state,
                                          onOnboard: () => _bloc.add(
                                            InterviewOnboardSubmitted(
                                                state.selectedIds),
                                          ),
                                          onReject: () => _bloc.add(
                                            InterviewRejectSubmitted(
                                                state.selectedIds),
                                          ),
                                          onSchedule: () => _bloc.add(
                                            InterviewScheduleSubmitted(
                                                state.selectedIds),
                                          ),
                                          onSelect: () => _bloc.add(
                                            InterviewSelectSubmitted(
                                                state.selectedIds),
                                          ),
                                        ),
                                        onSelectedIdsChanged: (ids) =>
                                            _bloc.add(
                                                InterviewSelectionChanged(ids)),
                                      ),
                                    )
                                  : const Center(
                                      key: ValueKey('empty'),
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: EmptyContent(
                                          icon:
                                              'assets/icons/empty/ic-folder-empty.svg',
                                          title: 'No candidates',
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openFilterPanel(
    BuildContext context,
    ThemeData theme,
    InterviewSchedulingState state,
  ) {
    showRightSideTaskDetails(
      context,
      InterviewFilterPanel(
        selectedJob: state.selectedJob,
        selectedInterviewer: state.selectedInterviewer,
        selectedStatus: state.selectedStatus,
        selectedDateRange: state.selectedDateRange,
        jobOptions: state.jobOptions,
        interviewerOptions: state.interviewerOptions,
        statusOptions: state.statusOptions,
        onReset: () => _bloc.add(InterviewFiltersReset()),
        onApply: ({
          required String job,
          required String interviewer,
          required String status,
          required DateTimeRange? range,
        }) =>
            _bloc.add(
          InterviewFiltersApplied(
            job: job,
            interviewer: interviewer,
            status: status,
            range: range,
          ),
        ),
      ),
      widthFactor: 0.7,
    );
  }
}
