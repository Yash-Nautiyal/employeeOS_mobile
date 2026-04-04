import 'package:employeeos/core/common/components/custom_toast.dart';
import 'package:employeeos/core/common/components/empty_content.dart';
import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, UserInfoService, showRightSideTaskDetails;
import 'package:employeeos/core/user/user_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../domain/interview_scheduling/entities/interview_enums.dart';
import '../../domain/interview_scheduling/entities/interview_schedule_details.dart';
import '../bloc/interview_scheduling/interview_scheduling_bloc.dart';
import '../widget/index.dart'
    show
        ActionHeader,
        CandidateTabs,
        CandidatesTable,
        InterviewFilterPanel,
        InterviewRoundsTab;
import '../utils/interview_calendar_event_copy.dart';
import '../utils/calendar/open_google_calendar.dart';
import '../widget/interview_scheduling/dialogs/schedule_interview_dialogs.dart';
import '../widget/interview_scheduling/interview_scheduling_injection.dart';
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
    _bloc = InterviewSchedulingInjection.createBloc();

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

  void _onSearchQueryChanged(String value) {
    _bloc.add(InterviewSearchChanged(value));
  }

  void _onFiltersReset() {
    _bloc.add(InterviewFiltersReset());
  }

  void _onFiltersApplied({
    required String job,
    required String interviewer,
    required String status,
    required DateTimeRange? range,
  }) {
    _bloc.add(
      InterviewFiltersApplied(
        job: job,
        interviewer: interviewer,
        status: status,
        range: range,
      ),
    );
  }

  void _onSelectionChanged(Set<String> ids) {
    _bloc.add(InterviewSelectionChanged(ids));
  }

  void _onOnboardPressed(Set<String> ids) {
    _bloc.add(InterviewOnboardSubmitted(ids));
  }

  void _onRejectPressed(Set<String> ids) {
    _bloc.add(InterviewRejectSubmitted(ids));
  }

  void _onSelectPressed(Set<String> ids) {
    _bloc.add(InterviewSelectSubmitted(ids));
  }

  void _onFlushPressed(Set<String> ids) {
    _bloc.add(InterviewFlushSubmitted(ids));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || screenWidth > 700;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<InterviewSchedulingBloc, InterviewSchedulingState>(
        listenWhen: (previous, current) =>
            current is InterviewSchedulingListenState,
        listener: (context, state) {
          if (state is InterviewSchedulingError) {
            showCustomToast(
              context: context,
              type: ToastificationType.error,
              title: 'Error',
              description: state.message,
            );
          }
        },
        child: BlocConsumer<InterviewSchedulingBloc, InterviewSchedulingState>(
          listenWhen: (previous, current) {
            final cr = current is InterviewSchedulingReady ? current : null;
            final pr = previous is InterviewSchedulingReady ? previous : null;
            if (cr == null) return false;
            return pr?.activeTab != cr.activeTab ||
                pr?.activeRound != cr.activeRound;
          },
          listener: (context, state) {
            if (state is! InterviewSchedulingReady) return;
            if (state.activeRound.usesEligibleScheduledTabs &&
                _candidateTabController.index != state.activeTab.index) {
              _candidateTabController.animateTo(state.activeTab.index);
            }
            if (_roundTabController.index != state.activeRound.index) {
              _roundTabController.animateTo(state.activeRound.index);
            }
          },
          buildWhen: (previous, current) =>
              current is! InterviewSchedulingListenState,
          builder: (context, state) {
            final theme = Theme.of(context);

            if (state is InterviewSchedulingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InterviewSchedulingFetchError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is! InterviewSchedulingReady) {
              return const SizedBox.shrink();
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
                          onSearchChanged: _onSearchQueryChanged,
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
                                          showResumeColumn: state.activeRound !=
                                                  InterviewRound.selected &&
                                              state.activeRound !=
                                                  InterviewRound.onboarding &&
                                              state.activeRound !=
                                                  InterviewRound.rejected,
                                          actionToolbar:
                                              InterviewTableActionTools(
                                            theme: theme,
                                            state: state,
                                            onOnboard: () => _onOnboardPressed(
                                              state.selectedIds,
                                            ),
                                            onReject: () => _onRejectPressed(
                                              state.selectedIds,
                                            ),
                                            onSchedule: () =>
                                                _openGoogleCalendarForScheduling(
                                              state,
                                            ),
                                            onSelect: () => _onSelectPressed(
                                              state.selectedIds,
                                            ),
                                            onFlush: () => _onFlushPressed(
                                              state.selectedIds,
                                            ),
                                          ),
                                          onSelectedIdsChanged:
                                              _onSelectionChanged,
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
      ),
    );
  }

  /// Form → Google Calendar (TEMPLATE) → confirmation → optional pipeline update.
  Future<void> _openGoogleCalendarForScheduling(
    InterviewSchedulingReady state,
  ) async {
    if (state.selectedIds.isEmpty) return;
    if (!state.activeRound.usesEligibleScheduledTabs ||
        state.activeTab != InterviewCandidateTab.eligible) {
      return;
    }

    // Snapshot before awaits — [state] from build can be stale after dialogs / resume.
    final applicationIds = Set<String>.from(state.selectedIds);
    final activeRound = state.activeRound;

    final userInfoService = context.read<UserInfoService>();
    final form = await showScheduleInterviewFormDialog(
      context: context,
      theme: Theme.of(context),
      userInfoService: userInfoService,
      round: activeRound,
    );

    if (!mounted || form == null) return;

    final selectedCandidates = state.candidates
        .where((candidate) => applicationIds.contains(candidate.id))
        .toList();
    final applicantEmails = selectedCandidates
        .map((candidate) => candidate.email.trim())
        .where(_looksLikeEmail)
        .toSet()
        .toList();
    final organizerEmail =
        Supabase.instance.client.auth.currentUser?.email?.trim() ?? '';

    final interviewerName = _hrDisplayName(form.interviewer);
    final assignedByName = _hrDisplayName(form.assignedBy);

    final candidateNamesSummary = selectedCandidates
        .map((c) => c.name.trim())
        .where((n) => n.isNotEmpty)
        .join(', ');

    final title = buildCalendarEventTitle(activeRound);
    final details = buildCalendarEventDetails(
      round: activeRound,
      interviewerName: interviewerName,
      assignedByName: assignedByName,
      selectedCount: applicationIds.length,
      candidateNamesSummary: candidateNamesSummary,
    );

    // Guests: organizer (logged-in user) + selected applicants + interviewer.
    // [Set] dedupes so the same email is never added twice.
    final guests = <String>{
      if (_looksLikeEmail(organizerEmail)) organizerEmail,
      ...applicantEmails,
      if (_looksLikeEmail(form.interviewer.email))
        form.interviewer.email.trim(),
    }.toList();

    final ok = await openGoogleCalendarTemplateEvent(
      title: title,
      startLocal: form.startLocal,
      endLocal: form.endLocal,
      details: details,
      guests: guests,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Calendar')),
      );
      return;
    }

    final confirmed = await showMeetingScheduledConfirmationDialog(
      context: context,
      theme: Theme.of(context),
    );

    if (!mounted) return;
    if (confirmed) {
      _bloc.add(
        InterviewScheduleSubmitted(
          applicationIds,
          InterviewScheduleDetails(
            scheduleStart: form.startLocal.toUtc(),
            interviewerLabel: _hrDisplayName(form.interviewer),
            assignedByLabel: _hrDisplayName(form.assignedBy),
          ),
        ),
      );
    }
  }

  String _hrDisplayName(UserInfoEntity u) {
    final name = u.fullName.trim();
    if (name.isNotEmpty) return name;
    final email = u.email.trim();
    if (email.isNotEmpty) return email;
    return '—';
  }

  bool _looksLikeEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  }

  void _openFilterPanel(
    BuildContext context,
    ThemeData theme,
    InterviewSchedulingReady state,
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
        onReset: _onFiltersReset,
        onApply: ({
          required String job,
          required String interviewer,
          required String status,
          required DateTimeRange? range,
        }) =>
            _onFiltersApplied(
          job: job,
          interviewer: interviewer,
          status: status,
          range: range,
        ),
      ),
      widthFactor: 0.7,
    );
  }
}
