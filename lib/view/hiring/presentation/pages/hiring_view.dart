import 'package:employeeos/core/common/components/custom_title_header.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_filters.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_chart.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_pipelines.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_metric.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_stats_card.dart';
import 'package:flutter/material.dart';

class HiringView extends StatefulWidget {
  const HiringView({super.key});

  @override
  State<HiringView> createState() => _HiringViewState();
}

class _HiringViewState extends State<HiringView> {
  final _searchController = TextEditingController();
  final _postingDateFromController = TextEditingController();
  final _postingDateToController = TextEditingController();
  final _lastDateFromController = TextEditingController();
  final _lastDateToController = TextEditingController();
  List<bool> expandedStates = [];
  late List<HiringPipelineData> hiringData;
  String? selectedJob;
  String? selectedHR;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _postingDateFromController.dispose();
    _postingDateToController.dispose();
    _lastDateFromController.dispose();
    _lastDateToController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10)
              .copyWith(top: 10, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              HiringFilters(
                selectedJob: selectedJob,
                selectedHR: selectedHR,
                theme: theme,
                postingDateFromController: _postingDateFromController,
                postingDateToController: _postingDateToController,
                lastDateFromController: _lastDateFromController,
                lastDateToController: _lastDateToController,
              ),
              const SizedBox(height: 10),
              _buildStatsSection(theme),
              const SizedBox(height: 20),
              SizedBox(
                height: 480,
                child: PageView(
                    padEnds: false,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      HiringJobChart(theme: theme),
                      Container(
                        width: double.infinity,
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
                              subtitle:
                                  'Track application and interview progress',
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border(
                                    top: BorderSide(
                                      color: theme.dividerColor.withAlpha(100),
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                  bottom: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Headers with proper spacing
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Application Progress',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Interview Progress',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Metrics in a flexible layout that uses full height
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Row 1
                                          Row(
                                            children: [
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Shortlisted',
                                                  value: '10',
                                                  showCircle: true,
                                                  circleColor: Colors.orange,
                                                  theme: theme,
                                                  big: true,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Telephonic',
                                                  value: '10',
                                                  showCircle: true,
                                                  circleColor: Colors.blue,
                                                  theme: theme,
                                                  subtitle: true,
                                                  big: true,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Row 2
                                          Row(
                                            children: [
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Technical',
                                                  value: '10',
                                                  showCircle: true,
                                                  circleColor: Colors.green,
                                                  theme: theme,
                                                  big: true,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Onboarding',
                                                  value: '10',
                                                  showCircle: true,
                                                  circleColor: Colors.purple,
                                                  theme: theme,
                                                  subtitle: true,
                                                  big: true,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Row 3
                                          Row(
                                            children: [
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Pending',
                                                  value: '10',
                                                  showCircle: true,
                                                  theme: theme,
                                                  big: true,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: HiringPipelineMetric(
                                                  title: 'Rejected',
                                                  value: '10',
                                                  showCircle: true,
                                                  theme: theme,
                                                  subtitle: true,
                                                  big: true,
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
                            ),
                          ],
                        ),
                      )
                    ]),
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
                          )),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CustomTitleHeader(
                      theme: theme,
                      title: 'Job-wise Hiring Pipeline',
                      subtitle: 'Detailed pipeline status for each job posting',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0).copyWith(top: 15),
                      child: HiringJobPipelines(
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HiringStatsCard(
                title: 'Total Applications',
                value: '619',
                height: 120,
                iconPath: 'assets/icons/common/solid/ic-solar-clipboard.svg',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: HiringStatsCard(
                title: 'Total Shortlisted',
                value: '0',
                valueColor: AppPallete.primaryMain,
                height: 120,
                iconPath: 'assets/icons/common/solid/ic-mingcute-target.svg',
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        HiringStatsCard(
          title: 'Total Rejected',
          value: '0',
          valueColor: AppPallete.errorMain,
          height: 80,
          ishorizontal: true,
          width: double.infinity,
          iconPath: 'assets/icons/common/solid/ic-solar-shield-warning.svg',
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: HiringStatsCard(
                title: 'Pending',
                value: '619',
                valueColor: AppPallete.warningMain,
                height: 110,
                iconPath: 'assets/icons/common/solid/ic-alert.svg',
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: HiringStatsCard(
                title: 'Jobs',
                value: '4',
                valueColor: AppPallete.successMain,
                height: 110,
                iconPath: 'assets/icons/common/solid/ic-solar-case.svg',
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: HiringStatsCard(
                title: 'Positions',
                value: '6',
                valueColor: AppPallete.infoMain,
                height: 110,
                iconPath: 'assets/icons/common/solid/ic-solar-user.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
