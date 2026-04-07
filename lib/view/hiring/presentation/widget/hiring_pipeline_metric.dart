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

  /// Arc fill 0.0–1.0 (ignored when [showCircle] is false).
  final double progress;

  const HiringPipelineMetric({
    super.key,
    this.circleColor,
    this.showCircle = false,
    this.subtitle,
    this.big = false,
    required this.title,
    required this.value,
    required this.theme,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pointerValue =
        (progress * 100).clamp(0.0, 100.0).toDouble();
    final subtitleText = (subtitle != null && subtitle!.trim().isNotEmpty)
        ? ' ${subtitle!.trim()}'
        : '';

    return Row(
      children: [
        if (showCircle!) ...[
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.2),
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
                        value: pointerValue,
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
          const SizedBox(width: 5),
        ] else ...[
          const SizedBox(width: 30),
        ],
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.bodySmall),
              RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.disabledColor, fontSize: 13),
                    ),
                    TextSpan(
                      text: subtitleText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
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
