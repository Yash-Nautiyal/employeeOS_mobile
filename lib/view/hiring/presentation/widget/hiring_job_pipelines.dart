import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_metric.dart';
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
  const HiringJobPipelines({
    super.key,
    required this.theme,
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
    return Column(
      children: List.generate(hiringData.length, (index) {
        final job = hiringData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Column(children: [
            InkWell(
              onTap: () {
                setState(() {
                  for (int i = 0; i < expandedStates.length; i++) {
                    expandedStates[i] = i == index ? !expandedStates[i] : false;
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

            // Expanded Content with animation
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
                        key: ValueKey('expanded-$index'),
                        decoration: BoxDecoration(
                          color: widget.theme.scaffoldBackgroundColor,
                          border: Border(
                            top: BorderSide(
                              color: widget.theme.dividerColor.withAlpha(100),
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 24, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Application Progress and Interview Progress Headers
                            Row(
                              children: [
                                Text(
                                  'Application Progress',
                                  style: widget.theme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Interview Progress',
                                  style: widget.theme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Example metrics for demo
                            Row(
                              children: [
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Shortlisted',
                                    value: job.shortlisted.toString(),
                                    showCircle: true,
                                    circleColor: Colors.orange,
                                    theme: widget.theme,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Telephonic',
                                    value: job.telephonic.toString(),
                                    showCircle: true,
                                    circleColor: Colors.blue,
                                    theme: widget.theme,
                                    subtitle: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Technical',
                                    value: job.technical.toString(),
                                    showCircle: true,
                                    circleColor: Colors.green,
                                    theme: widget.theme,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Onboarding',
                                    value: job.onboarding.toString(),
                                    showCircle: true,
                                    circleColor: Colors.purple,
                                    theme: widget.theme,
                                    subtitle: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Pending',
                                    value: job.pending.toString(),
                                    showCircle: true,
                                    theme: widget.theme,
                                  ),
                                ),
                                Expanded(
                                  child: HiringPipelineMetric(
                                    title: 'Rejected',
                                    value: job.rejected.toString(),
                                    showCircle: true,
                                    theme: widget.theme,
                                    subtitle: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
        );
      }),
    );
  }
}
