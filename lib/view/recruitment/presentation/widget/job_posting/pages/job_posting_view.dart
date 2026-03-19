import 'package:employeeos/core/index.dart'
    show
        CustomBreadCrumbs,
        CustomTextfield,
        Popup,
        PopupPreferredPosition,
        ResponsivePopupController,
        ResponsivePopupItem,
        showRightSideTaskDetails;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:employeeos/core/auth/bloc/auth_bloc.dart';

import 'package:employeeos/view/recruitment/data/index.dart'
    show JobPostingMockDatasource, JobPostingModel;
import 'package:employeeos/view/recruitment/presentation/index.dart'
    show JobPostingSection, JobPostingCard;
import 'add_pages/add_department_page.dart';
import 'add_pages/add_job_posting_page.dart';
import 'job_filter_panel.dart';

class JobPostingView extends StatefulWidget {
  const JobPostingView({super.key});

  @override
  State<JobPostingView> createState() => _JobPostingViewState();
}

class _JobPostingViewState extends State<JobPostingView> {
  final scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();
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
    _popupController.dispose();
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

      if (_filterJobId.trim().isNotEmpty &&
          !job.id.toLowerCase().contains(_filterJobId.trim().toLowerCase())) {
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
    final canManageDepartment = profile?.canManageGlobalConfig ?? false;

    return SingleChildScrollView(
      controller: scrollController,
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 16.0),
            height: 70,
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
                  Popup(
                      popupAnchorKey: _popupAnchorKey,
                      layerLink: _layerLink,
                      popupController: _popupController,
                      preferredPosition: PopupPreferredPosition.bottom,
                      manualOffset: const Offset(-10, 0),
                      width: 170,
                      arrowOffset: 0.95,
                      icon: SvgPicture.asset(
                        'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
                        width: 30,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.tertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                      items: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ResponsivePopupItem(
                            title: 'Add Posting',
                            svgIcon: 'assets/icons/nav/ic-job.svg',
                            onTap: () async {
                              _popupController.hide();
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute<bool>(
                                  builder: (_) => const AddJobPostingPage(),
                                ),
                              );
                              if (result == true && mounted) {
                                _refreshJobs();
                              }
                            },
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        if (canManageDepartment)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 10),
                            child: ResponsivePopupItem(
                              title: 'Add Department',
                              svgIcon:
                                  'assets/icons/common/duotone/ic-solar-server-bold-duotone.svg',
                              onTap: () {
                                _popupController.hide();
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AddDepartmentPage(),
                                  ),
                                );
                              },
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                      ])
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 5,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        constraints:
                            const BoxConstraints(maxWidth: 200, minWidth: 100),
                        height: 46,
                        child: CustomTextfield(
                          controller: _searchController,
                          onchange: (_) => setState(() {}),
                          keyboardType: TextInputType.text,
                          theme: theme,
                          hintText: 'Search...',
                          isSearchField: true,
                          close: true,
                          onClose: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                      InkWell(
                        onTap: _openFilterPanel,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Filters',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.filter_list_rounded,
                                size: 18, color: theme.iconTheme.color),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sort by: ',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Latest', child: Text('Latest')),
                                DropdownMenuItem(
                                    value: 'Oldest', child: Text('Oldest')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _sortBy = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: jobs.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final canEditAndDelete = profile != null &&
                          (profile.canManageAnyJob ||
                              (profile.canManageOwnJobs &&
                                  job.postedByEmail == profile.email));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: JobPostingCard(
                          theme: theme,
                          job: job,
                          canEditAndDelete: canEditAndDelete,
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
                        ),
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
