import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:employeeos/core/common/components/popup/responsive_popup.dart';
import 'package:employeeos/core/common/components/popup/responsive_popup_item.dart';
import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/view/recruitment/data/datasources/job_posting_mock_datasource.dart';
import 'package:employeeos/view/recruitment/data/models/job_posting_model.dart';
import 'package:employeeos/view/recruitment/index.dart' show JobPostingCard;
import 'package:employeeos/view/recruitment/presentation/pages/job_posting_section.dart';
import 'package:employeeos/view/recruitment/presentation/pages/add_department_page.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/add_job_posting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JobPostingView extends StatefulWidget {
  const JobPostingView({super.key});

  @override
  State<JobPostingView> createState() => _JobPostingViewState();
}

class _JobPostingViewState extends State<JobPostingView> {
  final scrollController = ScrollController();
  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();
  final _mockDatasource = JobPostingMockDatasource.instance;
  late Future<List<JobPostingModel>> _jobsFuture;

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
    _popupController.dispose();
    super.dispose();
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
                            onTap: () {
                              _popupController.hide();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AddJobPostingPage(),
                                ),
                              );
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
                                  'assets/icons/common/solid/ic-solar-server-bold-duotone.svg',
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
                  final jobs = snapshot.data!;
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
