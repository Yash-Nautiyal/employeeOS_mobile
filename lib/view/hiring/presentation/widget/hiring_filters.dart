import 'package:employeeos/core/common/components/custom_dropdown.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HiringFilters extends StatefulWidget {
  final ThemeData theme;
  final String? selectedJob;
  final String? selectedHR;
  final TextEditingController postingDateFromController;
  final TextEditingController postingDateToController;
  final TextEditingController lastDateFromController;
  final TextEditingController lastDateToController;
  final bool initiallyExpanded;

  const HiringFilters({
    super.key,
    required this.theme,
    required this.postingDateFromController,
    required this.postingDateToController,
    required this.lastDateFromController,
    required this.lastDateToController,
    this.selectedJob,
    this.selectedHR,
    this.initiallyExpanded = false,
  });

  @override
  State<HiringFilters> createState() => _HiringFiltersState();
}

class _HiringFiltersState extends State<HiringFilters>
    with SingleTickerProviderStateMixin {
  late String? selectedJob;
  String? selectedHR;
  late TextEditingController _postingDateFromController;
  late TextEditingController _postingDateToController;
  late TextEditingController _lastDateFromController;
  late TextEditingController _lastDateToController;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedJob = widget.selectedJob;
    selectedHR = widget.selectedHR;
    _postingDateFromController = widget.postingDateFromController;
    _postingDateToController = widget.postingDateToController;
    _lastDateFromController = widget.lastDateFromController;
    _lastDateToController = widget.lastDateToController;
    _isExpanded = widget.initiallyExpanded;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create expand animation
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Create icon rotation animation
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _clearFilters() {
    setState(() {
      selectedJob = null;
      selectedHR = null;
      _postingDateFromController.clear();
      _postingDateToController.clear();
      _lastDateFromController.clear();
      _lastDateToController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with toggle button
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    color: widget.theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  // Active filters indicator
                  if (_hasActiveFilters())
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActiveFiltersCount().toString(),
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Animated chevron icon
                  AnimatedBuilder(
                    animation: _iconRotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _iconRotationAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Animated divider
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Container(
                height: _expandAnimation.value * 1,
                color: widget.theme.colorScheme.outline.withOpacity(0.2),
              );
            },
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: CustomDropdown(
                                items: [
                                  'Developer',
                                  'Designer',
                                  'Manager',
                                  'Analyst'
                                ]
                                    .map((job) => DropdownMenuItem(
                                          value: job,
                                          child: Text(
                                            job,
                                            style: widget
                                                .theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChange: (value) {
                                  setState(() {
                                    selectedJob = value;
                                  });
                                },
                                value: selectedJob,
                                label: 'Select Job',
                                theme: widget.theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: CustomDropdown(
                                label: 'Filter by HR',
                                items: [
                                  'HR Manager 1',
                                  'HR Manager 2',
                                  'HR Manager 3'
                                ]
                                    .map((hr) => DropdownMenuItem(
                                          value: hr,
                                          child: Text(
                                            hr,
                                            style: widget
                                                .theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                theme: widget.theme,
                                value: selectedHR,
                                onChange: (value) {
                                  setState(() {
                                    selectedHR = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: IntrinsicWidth(
                          stepWidth: 53,
                          child: CustomTextfield(
                            controller: _postingDateFromController,
                            keyboardType: TextInputType.datetime,
                            theme: widget.theme,
                            onchange: (value) {
                              // Handle date change
                            },
                            hintText: 'Posting Date From',
                            labelText: 'Posting Date From',
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: IntrinsicWidth(
                          stepWidth: 38,
                          child: CustomTextfield(
                            controller: _postingDateToController,
                            keyboardType: TextInputType.datetime,
                            theme: widget.theme,
                            onchange: (value) {
                              // Handle date change
                            },
                            hintText: 'Posting Date To',
                            labelText: 'Posting Date To',
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: IntrinsicWidth(
                          stepWidth: 30,
                          child: CustomTextfield(
                            controller: _lastDateFromController,
                            keyboardType: TextInputType.datetime,
                            theme: widget.theme,
                            onchange: (value) {
                              // Handle date change
                            },
                            hintText: 'Last Date From',
                            labelText: 'Last Date From',
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: IntrinsicWidth(
                          stepWidth: 40,
                          child: CustomTextfield(
                            controller: _lastDateToController,
                            keyboardType: TextInputType.datetime,
                            theme: widget.theme,
                            onchange: (value) {
                              // Handle date change
                            },
                            hintText: 'Last Date To',
                            labelText: 'Last Date To',
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: CustomTextButton(
                          backgroundColor:
                              widget.theme.colorScheme.errorContainer
                                  // ignore: deprecated_member_use
                                  .withOpacity(.5),
                          onClick: () => _clearFilters(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar-eraser-bold.svg',
                                color: widget.theme.colorScheme.error,
                                height: 22,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Clear ',
                                style: widget.theme.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: widget.theme.colorScheme.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedJob != null ||
        selectedHR != null ||
        _postingDateFromController.text.isNotEmpty ||
        _postingDateToController.text.isNotEmpty ||
        _lastDateFromController.text.isNotEmpty ||
        _lastDateToController.text.isNotEmpty;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (selectedJob != null) count++;
    if (selectedHR != null) count++;
    if (_postingDateFromController.text.isNotEmpty) count++;
    if (_postingDateToController.text.isNotEmpty) count++;
    if (_lastDateFromController.text.isNotEmpty) count++;
    if (_lastDateToController.text.isNotEmpty) count++;
    return count;
  }
}
