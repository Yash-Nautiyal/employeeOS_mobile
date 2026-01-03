import 'package:employeeos/core/index.dart'
    show CustomBreadCrumbs, showRightSideTaskDetails;
import 'package:employeeos/view/recruitment/index.dart'
    show
        ActionHeader,
        CandidateTabs,
        CandidatesTable,
        InterviewFilterPanel,
        InterviewRoundsTab;
import 'package:flutter/material.dart';

class InterviewSchedulingView extends StatefulWidget {
  const InterviewSchedulingView({super.key});

  @override
  State<InterviewSchedulingView> createState() =>
      _InterviewSchedulingViewState();
}

class _InterviewSchedulingViewState extends State<InterviewSchedulingView>
    with TickerProviderStateMixin {
  late TabController _roundTabController;
  late TabController _candidateTabController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedJob = 'All Jobs';
  String _selectedInterviewer = 'All Interviewers';
  String _selectedStatus = 'All';
  DateTimeRange? _selectedRange;

  List<String> get _jobOptions =>
      ['All Jobs', ..._dedup(_candidates.map((c) => c['jobId'] ?? ''))];
  List<String> get _interviewerOptions => [
        'All Interviewers',
        ..._dedup(_candidates.map((c) => c['interviewer'] ?? ''))
      ];
  List<String> get _statusOptions =>
      ['All', ..._dedup(_candidates.map((c) => c['status'] ?? ''))];

  final List<Map<String, String>> _candidates = [
    {
      'id': '1',
      'name': 'Yash katara',
      'jobTitle': 'AWS Cloud Intern',
      'applicationDate': '16 Apr 2025',
      'date': '2025-04-16',
      'jobId': 'AWS-01',
      'interviewer': 'Alex Chen',
      'status': 'Eligible',
    },
    {
      'id': '2',
      'name': 'Lakshman Reddy Thummala',
      'jobTitle': 'Full Stack Developer',
      'applicationDate': '15 Apr 2025',
      'date': '2025-04-15',
      'jobId': 'FS-02',
      'interviewer': 'Maria Garcia',
      'status': 'Eligible',
    },
    {
      'id': '3',
      'name': 'Priya Sharma',
      'jobTitle': 'Frontend Developer',
      'applicationDate': '14 Apr 2025',
      'date': '2025-04-14',
      'jobId': 'FE-03',
      'interviewer': 'Alex Chen',
      'status': 'Scheduled',
    },
    {
      'id': '4',
      'name': 'Rahul Kumar',
      'jobTitle': 'Backend Developer',
      'applicationDate': '13 Apr 2025',
      'date': '2025-04-13',
      'jobId': 'BE-04',
      'interviewer': 'Sam Lee',
      'status': 'Eligible',
    },
    {
      'id': '5',
      'name': 'Anjali Gupta',
      'jobTitle': 'DevOps Engineer',
      'applicationDate': '12 Apr 2025',
      'date': '2025-04-12',
      'jobId': 'DEV-05',
      'interviewer': 'Maria Garcia',
      'status': 'Scheduled',
    },
    {
      'id': '6',
      'name': 'Vikram Singh',
      'jobTitle': 'Data Analyst',
      'applicationDate': '11 Apr 2025',
      'date': '2025-04-11',
      'jobId': 'DA-06',
      'interviewer': 'Sam Lee',
      'status': 'Eligible',
    },
    {
      'id': '7',
      'name': 'Sneha Patel',
      'jobTitle': 'UI/UX Designer',
      'applicationDate': '10 Apr 2025',
      'date': '2025-04-10',
      'jobId': 'UX-07',
      'interviewer': 'Alex Chen',
      'status': 'Scheduled',
    },
    {
      'id': '8',
      'name': 'Amit Verma',
      'jobTitle': 'Mobile Developer',
      'applicationDate': '09 Apr 2025',
      'date': '2025-04-09',
      'jobId': 'MB-08',
      'interviewer': 'Maria Garcia',
      'status': 'Eligible',
    },
    {
      'id': '9',
      'name': 'Kavita Rao',
      'jobTitle': 'QA Engineer',
      'applicationDate': '08 Apr 2025',
      'date': '2025-04-08',
      'jobId': 'QA-09',
      'interviewer': 'Sam Lee',
      'status': 'Eligible',
    },
    {
      'id': '10',
      'name': 'Suresh Reddy',
      'jobTitle': 'Product Manager',
      'applicationDate': '07 Apr 2025',
      'date': '2025-04-07',
      'jobId': 'PM-10',
      'interviewer': 'Alex Chen',
      'status': 'Scheduled',
    },
    {
      'id': '11',
      'name': 'Pooja Nair',
      'jobTitle': 'Business Analyst',
      'applicationDate': '06 Apr 2025',
      'date': '2025-04-06',
      'jobId': 'BA-11',
      'interviewer': 'Sam Lee',
      'status': 'Eligible',
    },
    {
      'id': '12',
      'name': 'Arjun Mehta',
      'jobTitle': 'Cloud Architect',
      'applicationDate': '05 Apr 2025',
      'date': '2025-04-05',
      'jobId': 'CA-12',
      'interviewer': 'Maria Garcia',
      'status': 'Eligible',
    },
  ];

  @override
  void initState() {
    super.initState();
    _roundTabController =
        TabController(length: 5, vsync: this, initialIndex: 1);
    _candidateTabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _candidateTabController.addListener(() {
      if (!mounted) return;
      if (_candidateTabController.indexIsChanging) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
// reset selection on tab change
        });
      });
    });
  }

  @override
  void dispose() {
    _roundTabController.dispose();
    _candidateTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final wideScreen = screenWidth > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;

    return SingleChildScrollView(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      child: Column(
        children: [
          CustomBreadCrumbs(
            theme: theme,
            heading: 'Interview Scheduling',
            routes: const ['Dashboard', 'Recruitment', 'Interview Scheduling'],
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
                  // Search and Filter Row
                  ActionHeader(
                    theme: theme,
                    isWideScreen: isWideScreen,
                    searchController: _searchController,
                    onFilterTap: () {
                      _openFilterPanel(context, theme, screenWidth);
                    },
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Round Tabs
                  InterviewRoundsTab(
                    theme: theme,
                    isWideScreen: isWideScreen,
                    controller: _roundTabController,
                  ),
                  const SizedBox(height: 20),

                  // Candidate Type Tabs and Schedule Button Row
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

                        // Table Content - using AnimatedSwitcher instead of TabBarView
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _candidateTabController.index == 0
                              ? CandidatesTable(
                                  key: const ValueKey('table'),
                                  screenWidth: screenWidth,
                                  candidates: _filteredCandidates(),
                                  onSelectionChanged: (count) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!mounted) return;
                                    });
                                  },
                                )
                              : Center(
                                  key: const ValueKey('empty'),
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Text(
                                      'No scheduled interviews',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.disabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Schedule Button for mobile
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _filteredCandidates() {
    final base = _candidateTabController.index == 0
        ? _candidates
        : _candidates.where((c) => (c['status'] ?? '') == 'Scheduled').toList();
    return base.where((c) {
      final name = (c['name'] ?? '').toLowerCase();
      final jobTitle = (c['jobTitle'] ?? '').toLowerCase();
      final jobId = c['jobId'] ?? '';
      final interviewer = c['interviewer'] ?? '';
      final status = c['status'] ?? '';
      final dateStr = c['date'] ?? '';

      if (_searchQuery.isNotEmpty &&
          !(name.contains(_searchQuery) || jobTitle.contains(_searchQuery))) {
        return false;
      }
      if (_selectedJob != 'All Jobs' && jobId != _selectedJob) return false;
      if (_selectedInterviewer != 'All Interviewers' &&
          interviewer != _selectedInterviewer) return false;
      if (_selectedStatus != 'All' && status != _selectedStatus) return false;
      if (_selectedRange != null) {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null) return false;
        if (parsed.isBefore(_selectedRange!.start) ||
            parsed.isAfter(_selectedRange!.end)) return false;
      }
      return true;
    }).toList();
  }

  void _openFilterPanel(
      BuildContext context, ThemeData theme, double screenWidth) {
    showRightSideTaskDetails(
      context,
      InterviewFilterPanel(
        selectedJob: _selectedJob,
        selectedInterviewer: _selectedInterviewer,
        selectedStatus: _selectedStatus,
        selectedDateRange: _selectedRange,
        jobOptions: _jobOptions,
        interviewerOptions: _interviewerOptions,
        statusOptions: _statusOptions,
        onReset: () {
          setState(() {
            _selectedJob = 'All Jobs';
            _selectedInterviewer = 'All Interviewers';
            _selectedStatus = 'All';
            _selectedRange = null;
          });
        },
        onApply: ({
          required String job,
          required String interviewer,
          required String status,
          required DateTimeRange? range,
        }) {
          setState(() {
            _selectedJob = job;
            _selectedInterviewer = interviewer;
            _selectedStatus = status;
            _selectedRange = range;
          });
        },
      ),
      widthFactor: 0.7,
    );
  }

  List<String> _dedup(Iterable<String> values) {
    return values.where((e) => e.isNotEmpty).toSet().toList();
  }
}
