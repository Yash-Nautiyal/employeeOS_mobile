import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_metric.dart';
import 'package:flutter/material.dart';

double _safeProgress(int numerator, int denominator) {
  if (denominator <= 0) return 0;
  return numerator / denominator;
}

class HiringPipelineContainer extends StatelessWidget {
  final ThemeData theme;
  final bool big;
  final PipelineOverview data;

  const HiringPipelineContainer({
    super.key,
    required this.theme,
    required this.big,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final ap = data.applicationProgress;
    final ip = data.interviewProgress;

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Application Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Interview Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Shortlisted',
                          value: '${ap.shortlisted}',
                          subtitle: 'of ${ap.total}',
                          progress: ap.total > 0 ? ap.shortlisted / ap.total : 0,
                          showCircle: true,
                          circleColor: AppPallete.successMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Telephonic',
                          value: '${ip.telephonic.active}',
                          subtitle:
                              'scheduled/completed out of ${ip.telephonic.eligible} eligible',
                          progress: _safeProgress(
                            ip.telephonic.active,
                            ip.telephonic.active + ip.telephonic.eligible,
                          ),
                          showCircle: true,
                          circleColor: AppPallete.infoMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Pending',
                          value: '${ap.pending}',
                          subtitle: 'of ${ap.total}',
                          progress: ap.total > 0 ? ap.pending / ap.total : 0,
                          showCircle: true,
                          circleColor: AppPallete.warningMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Technical',
                          value: '${ip.technical.active}',
                          subtitle:
                              'scheduled/completed out of ${ip.technical.eligible} eligible',
                          progress: _safeProgress(
                            ip.technical.active,
                            ip.technical.active + ip.technical.eligible,
                          ),
                          showCircle: true,
                          circleColor: AppPallete.secondaryMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Rejected',
                          value: '${ap.rejected}',
                          subtitle: 'of ${ap.total}',
                          progress: ap.total > 0 ? ap.rejected / ap.total : 0,
                          showCircle: true,
                          circleColor: AppPallete.errorMain,
                          theme: theme,
                          big: big,
                        ),
                      ),
                      Expanded(
                        child: HiringPipelineMetric(
                          title: 'Onboarding',
                          value: '${ip.onboarding.active}',
                          subtitle:
                              'in progress out of ${ip.onboarding.eligible} eligible',
                          progress: _safeProgress(
                            ip.onboarding.active,
                            ip.onboarding.active + ip.onboarding.eligible,
                          ),
                          showCircle: true,
                          circleColor: AppPallete.primaryMain,
                          theme: theme,
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
