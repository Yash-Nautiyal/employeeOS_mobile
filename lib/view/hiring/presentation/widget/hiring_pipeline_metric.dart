import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 20.h),
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
                      thickness: big ? 4 : 3,
                      color: theme.dividerColor.withAlpha(100),
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: 86.6,
                        width: big ? 5.5 : 4,
                        cornerStyle: CornerStyle.bothCurve,
                        pointerOffset: big ? -.8 : -.5,
                        color: circleColor ?? Colors.amber,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 1.w),
        ] else ...[
          SizedBox(width: 3.w), // Space for alignment when no circle
        ],
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 15.sp)),
              RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.disabledColor, fontSize: 15.sp),
                    ),
                    TextSpan(
                      text: subtitle != null ? ' $subtitle' : ' of 18',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
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
