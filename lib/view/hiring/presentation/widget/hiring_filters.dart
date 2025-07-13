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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle button
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: widget.theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filters',
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Active filters indicator
                  if (_hasActiveFilters())
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: widget.theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_getActiveFiltersCount()}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Animated chevron icon
                  AnimatedBuilder(
                    animation: _iconRotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _iconRotationAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          size: 20,
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
                color: widget.theme.disabledColor.withAlpha(100),
              );
            },
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Position & HR Section
                  _buildFilterSection(
                    title: 'Job Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
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
                                            fontWeight: FontWeight.w500,
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
                              label: 'Job Position',
                              theme: widget.theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomDropdown(
                              label: 'HR Manager',
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
                                            fontWeight: FontWeight.w500,
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Posting Date Section
                  _buildFilterSection(
                    title: 'Posting Date Range',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextfield(
                              controller: _postingDateFromController,
                              keyboardType: TextInputType.datetime,
                              theme: widget.theme,
                              onchange: (value) {
                                // Handle date change
                              },
                              hintText: 'Select start date',
                              labelText: 'From Date',
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextfield(
                              controller: _postingDateToController,
                              keyboardType: TextInputType.datetime,
                              theme: widget.theme,
                              onchange: (value) {
                                // Handle date change
                              },
                              hintText: 'Select end date',
                              labelText: 'To Date',
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Application Deadline Section
                  _buildFilterSection(
                    title: 'Application Deadline',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextfield(
                              controller: _lastDateFromController,
                              keyboardType: TextInputType.datetime,
                              theme: widget.theme,
                              onchange: (value) {
                                // Handle date change
                              },
                              hintText: 'Select start date',
                              labelText: 'From Date',
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextfield(
                              controller: _lastDateToController,
                              keyboardType: TextInputType.datetime,
                              theme: widget.theme,
                              onchange: (value) {
                                // Handle date change
                              },
                              hintText: 'Select end date',
                              labelText: 'To Date',
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextButton(
                          backgroundColor:
                              widget.theme.colorScheme.error.withOpacity(0.2),
                          onClick: () => _clearFilters(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar-eraser-bold.svg',
                                color: widget.theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Clear Filters',
                                style:
                                    widget.theme.textTheme.bodyMedium?.copyWith(
                                  color: widget.theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
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

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: widget.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.theme.colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
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
