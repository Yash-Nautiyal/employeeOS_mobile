import 'package:employeeos/core/common/components/custom_title_header.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HiringJobChart extends StatefulWidget {
  final ThemeData theme;
  final List<HiringData>? customData;

  const HiringJobChart({
    super.key,
    required this.theme,
    this.customData,
  });

  @override
  State<HiringJobChart> createState() => _HiringJobChartState();
}

class _HiringJobChartState extends State<HiringJobChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  List<HiringData> get _chartData {
    return widget.customData ??
        [
          HiringData(
            jobTitle: JobTitle.socialMediaManager,
            count: 15,
            color: AppPallete.primaryLighter, // Blue
          ),
          HiringData(
            jobTitle: JobTitle.awsCloudIntern,
            count: 8,
            color: AppPallete.primaryLight, // Green
          ),
          HiringData(
            jobTitle: JobTitle.englishContentWriter,
            count: 5,
            color: AppPallete.primaryDark, // Orange
          ),
          HiringData(
            jobTitle: JobTitle.videoEditor,
            count: 12,
            color: AppPallete.primaryDarker, // Purple
          ),
        ];
  }

  int get _totalPositions {
    return _chartData.fold(0, (sum, item) => sum + item.count);
  }

  @override
  Widget build(BuildContext context) {
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
            // Header
            CustomTitleHeader(
              theme: widget.theme,
              title: 'Positions by Job',
              subtitle: 'Distribution of open positions',
            ),
            const SizedBox(height: 20),
            // Chart
            Container(
              padding: const EdgeInsets.all(3.5),
              height: 350,
              width: double.maxFinite,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  duration: 500,
                  format: 'point.x: point.y positions',
                  textStyle: widget.theme.textTheme.bodySmall,
                  borderColor: widget.theme.colorScheme.outline,
                  color: widget.theme.colorScheme.inverseSurface,
                ),
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  alignment: ChartAlignment.center,
                  itemPadding: 8,
                  toggleSeriesVisibility: true,
                  textStyle: widget.theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  legendItemBuilder: (legendText, series, point, seriesIndex) {
                    final data = _chartData[seriesIndex];
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
                            data.jobTitle.displayName,
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
                    widget: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              widget.theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 24,
                            color: widget.theme.primaryColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total",
                            style: widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$_totalPositions",
                            style:
                                widget.theme.textTheme.headlineSmall?.copyWith(
                              color: widget.theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "Positions",
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                series: <CircularSeries>[
                  DoughnutSeries<HiringData, String>(
                    radius: "85%",
                    dataSource: _chartData,
                    xValueMapper: (HiringData data, _) =>
                        data.jobTitle.displayName,
                    yValueMapper: (HiringData data, _) => data.count,
                    pointColorMapper: (HiringData data, _) => data.color,
                    dataLabelMapper: (HiringData data, _) => '${data.count}',
                    innerRadius: '65%',
                    animationDuration: 700,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.line,
                        length: '15%',
                        color:
                            widget.theme.colorScheme.outline.withOpacity(0.5),
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
          ],
        ),
      ),
    );
  }
}
