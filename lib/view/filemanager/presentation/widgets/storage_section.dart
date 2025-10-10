import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StorageSection extends StatefulWidget {
  final ThemeData theme;
  const StorageSection({super.key, required this.theme});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // late final Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // _animation = CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeInOut,
    // );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStorageItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String fileCount,
    required String size,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 36,
          height: 36,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                fileCount,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(size,
            style: theme.textTheme.labelLarge?.copyWith(fontSize: 20.sp)),
      ],
    );
  }

  Widget _buildStorageHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Storage',
                style:
                    widget.theme.textTheme.displaySmall?.copyWith(fontSize: 20),
              ),
              if (!_isExpanded) ...[
                const SizedBox(height: 4),
                Text(
                  'Used 24GB of 50GB',
                  style: widget.theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (!_isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
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
                    thickness: 5,
                    color: theme.dividerColor.withAlpha(200),
                  ),
                  pointers: const <GaugePointer>[
                    RangePointer(
                      value: 86.6,
                      width: 8,
                      cornerStyle: CornerStyle.endCurve,
                      pointerOffset: -1.5,
                      color: AppPallete.secondaryLight,
                      gradient: SweepGradient(
                        colors: [
                          AppPallete.secondaryLight,
                          AppPallete.secondaryMain
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                height: _isExpanded ? 500 : 100,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStorageHeader(widget.theme),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isExpanded ? 200 : 0,
                        child: AnimatedOpacity(
                          duration: _isExpanded
                              ? const Duration(milliseconds: 400)
                              : const Duration(milliseconds: 200),
                          opacity: _isExpanded ? 1.0 : 0.0,
                          child: SfRadialGauge(
                            enableLoadingAnimation: true,
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 100,
                                startAngle: 180,
                                endAngle: 0,
                                showLabels: false,
                                showTicks: false,
                                canScaleToFit: true,
                                axisLineStyle: AxisLineStyle(
                                  thickness: 10,
                                  color: widget.theme.dividerColor,
                                  cornerStyle: CornerStyle.bothCurve,
                                ),
                                pointers: const <GaugePointer>[
                                  RangePointer(
                                    color: AppPallete.secondaryLight,
                                    value: 86.6,
                                    width: 25,
                                    pointerOffset: -7,
                                    cornerStyle: CornerStyle.bothCurve,
                                    gradient: SweepGradient(
                                      colors: [
                                        AppPallete.secondaryLight,
                                        AppPallete.secondaryMain
                                      ],
                                    ),
                                  ),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    verticalAlignment: GaugeAlignment.center,
                                    horizontalAlignment: GaugeAlignment.center,
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '86.6%',
                                          style: widget
                                              .theme.textTheme.displaySmall
                                              ?.copyWith(),
                                        ),
                                        Text(
                                          'Used of 24GB / 50 GB',
                                          style: widget
                                              .theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    angle: 90,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // Storage items with staggered animations
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset:
                            _isExpanded ? Offset.zero : const Offset(0, 0.5),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isExpanded ? 1.0 : 0.0,
                          child: Column(
                            children: [
                              _buildStorageItem(
                                theme: widget.theme,
                                icon: 'assets/icons/file/ic-img.svg',
                                title: 'Images',
                                fileCount: '12 files',
                                size: '3 GB',
                              ),
                              const SizedBox(height: 15),
                              _buildStorageItem(
                                theme: widget.theme,
                                icon: 'assets/icons/file/ic-video.svg',
                                title: 'Media',
                                fileCount: '122 files',
                                size: '1 GB',
                              ),
                              const SizedBox(height: 15),
                              _buildStorageItem(
                                theme: widget.theme,
                                icon: 'assets/icons/file/ic-document.svg',
                                title: 'Documents',
                                fileCount: '122 files',
                                size: '1 GB',
                              ),
                              const SizedBox(height: 15),
                              _buildStorageItem(
                                theme: widget.theme,
                                icon: 'assets/icons/file/ic-file.svg',
                                title: 'Other',
                                fileCount: '112 files',
                                size: '175 MB',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Positioned(
          bottom: _isExpanded ? -8 : -10,
          left: 0,
          right: 0,
          child: Hero(
            tag: 'storageButton',
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: _isExpanded ? 0.5 : 0,
                child: SvgPicture.asset(
                  'assets/icons/arrow/chevrons-down-alt-svgrepo-com.svg',
                  width: 24,
                  height: 24,
                  color: widget.theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
