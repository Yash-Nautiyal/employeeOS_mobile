// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/common/components/ui/custom_title_header.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _DonutSegment {
  final String label;
  final int value;
  final Color color;

  const _DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class HiringJobChart extends StatefulWidget {
  final ThemeData theme;
  final List<JobPositionData> data;

  const HiringJobChart({
    super.key,
    required this.theme,
    this.data = const [],
  });

  @override
  State<HiringJobChart> createState() => _HiringJobChartState();
}

class _HiringJobChartState extends State<HiringJobChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<Color> _segmentColors = [
    AppPallete.primaryLighter,
    AppPallete.primaryLight,
    AppPallete.primaryMain,
    AppPallete.primaryDark,
    AppPallete.primaryDarker,
  ];

  List<_DonutSegment> get _segments {
    print(widget.data);
    return widget.data.asMap().entries.map((e) {
      final i = e.key;
      final row = e.value;
      return _DonutSegment(
        label: row.jobTitle,
        value: row.positions,
        color: _segmentColors[i % _segmentColors.length],
      );
    }).toList();
  }

  int get _totalPositions {
    return widget.data.fold(0, (sum, item) => sum + item.positions);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segments = _segments;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitleHeader(
              theme: widget.theme,
              title: 'Positions by Job',
              subtitle: 'Distribution of open positions',
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                width: double.maxFinite,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    duration: 800,
                    format: 'point.x: point.y positions',
                    textStyle: widget.theme.textTheme.bodySmall,
                    borderColor: widget.theme.colorScheme.outline,
                    color: widget.theme.colorScheme.inverseSurface,
                  ),
                  legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    position: LegendPosition.bottom,
                    itemPadding: 0,
                    alignment: ChartAlignment.center,
                    toggleSeriesVisibility: true,
                    textStyle: widget.theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    legendItemBuilder:
                        (legendText, series, point, seriesIndex) {
                      final data = segments[seriesIndex];
                      print(data);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: data.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              data.label,
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: widget.theme.disabledColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  annotations: [
                    CircularChartAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SvgPicture.asset(
                              'assets/icons/common/solid/ic-mingcute-group-3-fill.svg',
                              color: widget.theme.primaryColor,
                            ),
                          ),
                          Text(
                            "Total",
                            style: widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.disabledColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$_totalPositions",
                            style: widget.theme.textTheme.titleLarge?.copyWith(
                              color: widget.theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "Positions",
                            style: widget.theme.textTheme.labelLarge?.copyWith(
                              color: widget.theme.disabledColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  series: <CircularSeries>[
                    DoughnutSeries<_DonutSegment, String>(
                      radius: "80%",
                      dataSource: segments,
                      xValueMapper: (_DonutSegment data, _) => data.label,
                      yValueMapper: (_DonutSegment data, _) => data.value,
                      pointColorMapper: (_DonutSegment data, _) => data.color,
                      dataLabelMapper: (_DonutSegment data, _) =>
                          '${data.value}',
                      innerRadius: '65%',
                      animationDuration: 700,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.line,
                          length: '5%',
                          color: widget.theme.colorScheme.tertiary
                              .withOpacity(0.5),
                        ),
                        textStyle: widget.theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
