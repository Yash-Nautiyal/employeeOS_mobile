import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HiringPipelineMetric extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final Color? circleColor;
  final bool? showCircle;
  final ThemeData theme;
  final bool big;
  const HiringPipelineMetric({
    super.key,
    this.circleColor,
    this.showCircle = false,
    this.subtitle,
    this.big = false,
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showCircle!) ...[
          SizedBox(
            width: big ? 50 : 40,
            height: big ? 50 : 40,
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 270,
                  endAngle: 270,
                  axisLineStyle: AxisLineStyle(
                    thickness: 3,
                    color: theme.dividerColor.withAlpha(100),
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: 86.6,
                      width: 4,
                      cornerStyle: CornerStyle.bothCurve,
                      pointerOffset: -.5,
                      color: circleColor ?? Colors.amber,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
        ] else ...[
          const SizedBox(width: 52), // Space for alignment when no circle
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.disabledColor),
                    ),
                    TextSpan(
                      text: subtitle != null ? ' $subtitle' : ' of 18',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
