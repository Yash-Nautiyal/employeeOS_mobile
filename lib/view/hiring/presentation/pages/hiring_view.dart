import 'package:employeeos/core/common/components/custom_title_header.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_filters.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_chart.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_job_pipelines.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_container.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

  final scrollController = ScrollController();
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
      controller: scrollController,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
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
            _buildStatsSection(theme, MediaQuery.of(context).size.height),
            const SizedBox(height: 20),
            _buildResponsiveChartsSection(theme),
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
                    subtitle: 'Detailed pipeline status for each job posting',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: HiringJobPipelines(
                      scrollController: scrollController,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveChartsSection(ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final shouldUseSideBySideLayout = !isPortrait || screenWidth > 600;

    if (!shouldUseSideBySideLayout) {
      // Vertical layout with PageView
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
                HiringJobChart(theme: theme),
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
                      SizedBox(height: 2.h),
                      Expanded(
                        child: HiringPipelineContainer(
                          theme: theme,
                          big: true,
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
    } else {
      // Side-by-side layout for wide screens or landscape mode
      return SizedBox(
        height: 440,
        child: Row(
          children: [
            Expanded(
              flex: screenWidth > 800
                  ? 1
                  : 2, // More space for chart on very wide screens
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: HiringJobChart(theme: theme),
              ),
            ),
            Expanded(
              flex:
                  screenWidth > 800 ? 1 : 3, // Equal space on very wide screens
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
                    SizedBox(height: 2.h),
                    Expanded(
                      child: HiringPipelineContainer(
                        theme: theme,
                        big: true,
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
  }

  Widget _buildStatsSection(ThemeData theme, double screenHeight) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final data = [
      {
        'title': 'Total Applications',
        'value': '619',
        'valueColor': AppPallete.grey600,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-clipboard.svg',
      },
      {
        'title': 'Total Shortlisted',
        'value': '0',
        'valueColor': AppPallete.primaryMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-mingcute-target.svg',
      },
      {
        'title': 'Total Rejected',
        'value': '0',
        'valueColor': AppPallete.errorMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-shield-warning.svg',
      },
      {
        'title': 'Pending',
        'value': '619',
        'valueColor': AppPallete.warningMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-alert.svg',
      },
      {
        'title': 'Jobs',
        'value': '4',
        'valueColor': AppPallete.successMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-case.svg',
      },
      {
        'title': 'Positions',
        'value': '6',
        'valueColor': AppPallete.infoMain,
        'height': isPortrait ? 120 : 100,
        'iconPath': 'assets/icons/common/solid/ic-solar-user.svg',
      },
    ];
    return HiringStatsCard(data: data);
  }
}
