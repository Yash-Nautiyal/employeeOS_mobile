import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_container.dart';
import 'package:flutter/material.dart';

// Data model for hiring pipeline
class HiringPipelineData {
  final String jobTitle;
  final int totalApplications;
  final int shortlisted;
  final int rejected;
  final int pending;
  final int telephonic;
  final int technical;
  final int onboarding;

  HiringPipelineData({
    required this.jobTitle,
    required this.totalApplications,
    required this.shortlisted,
    required this.rejected,
    required this.pending,
    required this.telephonic,
    required this.technical,
    required this.onboarding,
  });
}

class HiringJobPipelines extends StatefulWidget {
  final ThemeData theme;
  final ScrollController scrollController;
  const HiringJobPipelines({
    super.key,
    required this.theme,
    required this.scrollController,
  });

  @override
  State<HiringJobPipelines> createState() => _HiringJobPipelinesState();
}

class _HiringJobPipelinesState extends State<HiringJobPipelines>
    with TickerProviderStateMixin {
  List<bool> expandedStates = [];
  late List<HiringPipelineData> hiringData;

  @override
  void initState() {
    super.initState();
    hiringData = [
      HiringPipelineData(
        jobTitle: 'Social Media Manager',
        totalApplications: 18,
        shortlisted: 0,
        rejected: 0,
        pending: 18,
        telephonic: 0,
        technical: 0,
        onboarding: 0,
      ),
      HiringPipelineData(
        jobTitle: 'AWS Cloud Intern',
        totalApplications: 578,
        shortlisted: 45,
        rejected: 125,
        pending: 408,
        telephonic: 12,
        technical: 8,
        onboarding: 3,
      ),
      HiringPipelineData(
        jobTitle: 'English Content Writer',
        totalApplications: 12,
        shortlisted: 3,
        rejected: 2,
        pending: 7,
        telephonic: 2,
        technical: 1,
        onboarding: 0,
      ),
      HiringPipelineData(
        jobTitle: 'Video Editor',
        totalApplications: 11,
        shortlisted: 2,
        rejected: 1,
        pending: 8,
        telephonic: 1,
        technical: 1,
        onboarding: 0,
      ),
    ];
    expandedStates = List.generate(hiringData.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final shouldUseGridLayout = !isPortrait || screenWidth > 600;

    return shouldUseGridLayout
        ? GridView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: hiringData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .85, // Adjusted for better height
            ),
            itemBuilder: (context, index) {
              return _buildJobPipelineCard(index, isGridLayout: true);
            },
          )
        : Column(
            children: List.generate(
              hiringData.length,
              (index) => _buildJobPipelineCard(index, isGridLayout: false),
            ),
          );
  }

  Widget _buildJobPipelineCard(int index, {required bool isGridLayout}) {
    final job = hiringData[index];
    return Container(
      margin: EdgeInsets.only(top: isGridLayout ? 0 : 12),
      decoration: BoxDecoration(
        color: widget.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(
                widget.theme.brightness == Brightness.dark ? 0.3 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: isGridLayout
                ? null
                : () {
                    setState(() {
                      for (int i = 0; i < expandedStates.length; i++) {
                        expandedStates[i] =
                            i == index ? !expandedStates[i] : false;
                      }
                    });
                  },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: widget.theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: isGridLayout ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "(${job.totalApplications} Applications)",
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (!isGridLayout)
                    Icon(
                      expandedStates[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.theme.dividerColor,
                    ),
                ],
              ),
            ),
          ),

          // Expanded Content with animation - only for list layout
          if (!isGridLayout)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: expandedStates[index]
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        child: HiringPipelineContainer(
                          theme: widget.theme,
                          key: ValueKey('expanded-$index'),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          else
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: HiringPipelineContainer(
                  theme: widget.theme,
                  key: ValueKey('grid-expanded-$index'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
