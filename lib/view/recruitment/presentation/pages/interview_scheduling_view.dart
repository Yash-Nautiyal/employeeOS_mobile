import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, showRightSideTaskDetails;
import 'package:employeeos/view/recruitment/data/datasources/interview_scheduling_local_data_source.dart';
import 'package:employeeos/view/recruitment/data/repositories/interview_scheduling_repository_impl.dart';
import 'package:employeeos/view/recruitment/domain/entities/interview_enums.dart';
import 'package:employeeos/view/recruitment/domain/usecases/get_interview_candidates_usecase.dart';
import 'package:employeeos/view/recruitment/index.dart'
    show
        ActionHeader,
        CandidateTabs,
        CandidatesTable,
        InterviewFilterPanel,
        InterviewRoundsTab;
import 'package:employeeos/view/recruitment/presentation/bloc/interview_scheduling/interview_scheduling_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      const InterviewSchedulingLocalDataSource(),
    );
    _bloc = InterviewSchedulingBloc(
      getInterviewCandidatesUseCase: GetInterviewCandidatesUseCase(repository),
    );

    _roundTabController = TabController(
      length: InterviewRound.values.length,
      vsync: this,
      initialIndex: InterviewRound.technical.index,
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
          if (_candidateTabController.index != state.activeTab.index) {
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
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                                    ? CandidatesTable(
                                        key: const ValueKey('table'),
                                        screenWidth: screenWidth,
                                        candidates: state.filteredCandidates,
                                        selectedIds: state.selectedIds,
                                        onSelectedIdsChanged: (ids) =>
                                            _bloc.add(
                                                InterviewSelectionChanged(ids)),
                                        onSchedulePressed: (ids) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Schedule ${ids.length} candidate(s)',
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        key: const ValueKey('empty'),
                                        child: Padding(
                                          padding: const EdgeInsets.all(40.0),
                                          child: Text(
                                            'No candidates match your filters',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: theme.disabledColor,
                                            ),
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
