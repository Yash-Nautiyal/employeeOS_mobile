import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_metric.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HiringPipelineContainer extends StatelessWidget {
  final ThemeData theme;
  final String? shortlistedValue;
  final String? technicalValue;
  final String? pendingValue;
  final String? telephonicRound;
  final String? onboardingRound;
  final String? rejectedRound;
  final bool big;
  const HiringPipelineContainer({
    super.key,
    required this.theme,
    this.shortlistedValue,
    this.technicalValue,
    this.pendingValue,
    this.telephonicRound,
    this.onboardingRound,
    this.rejectedRound,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Headers with proper spacing
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Application Progress',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Interview Progress',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Metrics in a flexible layout that uses full height
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Row 1
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Shortlisted',
                          value: shortlistedValue ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.successMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Telephonic',
                          value: telephonicRound ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.infoMain,
                          theme: theme,
                          subtitle: 'scheduled/completed out of 0 eligible',
                          big: big,
                        ),
                      ),
                    ],
                  ),
                ),

                // Row 2
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Technical',
                          value: technicalValue ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.warningMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Onboarding',
                          value: onboardingRound ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.secondaryMain,
                          theme: theme,
                          subtitle: 'scheduled/completed out of 0 eligible',
                          big: big,
                        ),
                      ),
                    ],
                  ),
                ),

                // Row 3
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Pending',
                          value: pendingValue ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.secondaryLight,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Rejected',
                          value: rejectedRound ?? '10',
                          showCircle: true,
                          circleColor: AppPallete.errorMain,
                          theme: theme,
                          subtitle: 'in progress out of 0 eligible',
                          big: big,
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
  }
}
