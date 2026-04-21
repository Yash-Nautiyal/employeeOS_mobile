// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/common/components/dropdown/custom_dropdown.dart';
import 'package:employeeos/core/common/components/ui/custom_textbutton.dart';
import 'package:employeeos/core/common/components/ui/custom_textfield.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_bloc.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

DateTime? _parsePostingDate(String raw, {bool endOfDay = false}) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final parts = t.split('/');
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  final y = int.tryParse(parts[2].trim());
  if (d == null || m == null || y == null) return null;
  try {
    if (endOfDay) {
      return DateTime(y, m, d, 23, 59, 59, 999);
    }
    return DateTime(y, m, d);
  } catch (_) {
    return null;
  }
}

/// Normalizes [CustomTextfield] date `d/m/y` to `DD/MM/YYYY` for the RPC.
String? _normalizeDeadlineForRpc(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final parts = t.split('/');
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  final y = int.tryParse(parts[2].trim());
  if (d == null || m == null || y == null) return null;
  return '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/$y';
}

class HiringFilters extends StatefulWidget {
  final ThemeData theme;
  final TextEditingController postingDateFromController;
  final TextEditingController postingDateToController;
  final TextEditingController lastDateFromController;
  final TextEditingController lastDateToController;
  final HiringFilterParams appliedFilters;
  final List<JobOption> jobOptions;
  final List<HrOption> hrOptions;
  final bool showHrFilter;
  final bool initiallyExpanded;

  const HiringFilters({
    super.key,
    required this.theme,
    required this.postingDateFromController,
    required this.postingDateToController,
    required this.lastDateFromController,
    required this.lastDateToController,
    required this.appliedFilters,
    required this.jobOptions,
    required this.hrOptions,
    this.showHrFilter = false,
    this.initiallyExpanded = false,
  });

  @override
  State<HiringFilters> createState() => _HiringFiltersState();
}

class _HiringFiltersState extends State<HiringFilters>
    with SingleTickerProviderStateMixin {
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
    _postingDateFromController = widget.postingDateFromController;
    _postingDateToController = widget.postingDateToController;
    _lastDateFromController = widget.lastDateFromController;
    _lastDateToController = widget.lastDateToController;
    _isExpanded = widget.initiallyExpanded;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

  HiringFilterParams _collectParams({
    String? jobId,
    String? hrManagerId,
  }) {
    final hr = widget.showHrFilter ? hrManagerId : null;
    return HiringFilterParams(
      jobId: jobId,
      hrManagerId: hr,
      postingFrom: _parsePostingDate(_postingDateFromController.text),
      postingTo:
          _parsePostingDate(_postingDateToController.text, endOfDay: true),
      deadlineFrom: _normalizeDeadlineForRpc(_lastDateFromController.text),
      deadlineTo: _normalizeDeadlineForRpc(_lastDateToController.text),
    );
  }

  void _applyWithCurrentSelections() {
    context.read<HiringBloc>().add(
          HiringFiltersChanged(
            _collectParams(
              jobId: widget.appliedFilters.jobId,
              hrManagerId: widget.appliedFilters.hrManagerId,
            ),
          ),
        );
  }

  void _onJobChanged(String? value) {
    context.read<HiringBloc>().add(
          HiringFiltersChanged(
            _collectParams(
              jobId: value,
              hrManagerId: widget.appliedFilters.hrManagerId,
            ),
          ),
        );
  }

  void _onHrChanged(String? value) {
    context.read<HiringBloc>().add(
          HiringFiltersChanged(
            _collectParams(
              jobId: widget.appliedFilters.jobId,
              hrManagerId: value,
            ),
          ),
        );
  }

  void _clearFilters() {
    _postingDateFromController.clear();
    _postingDateToController.clear();
    _lastDateFromController.clear();
    _lastDateToController.clear();
    context.read<HiringBloc>().add(const HiringFiltersClearRequested());
  }

  List<DropdownMenuItem<String?>> _jobItems() {
    final style = widget.theme.textTheme.bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);
    return [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('All Jobs', style: style),
      ),
      ...widget.jobOptions.map((job) {
        final id = job.id;
        final title = job.title;
        return DropdownMenuItem<String?>(
          value: id.isEmpty ? null : id,
          child: Text(title, style: style),
        );
      }),
    ];
  }

  List<DropdownMenuItem<String?>> _hrItems() {
    final style = widget.theme.textTheme.bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);
    return [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('All', style: style),
      ),
      ...widget.hrOptions.map((row) {
        final id = row.id;
        final label = row.displayName;
        return DropdownMenuItem<String?>(
          value: id.isEmpty ? null : id,
          child: Text(label, style: style),
        );
      }),
    ];
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
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Container(
                height: _expandAnimation.value * 1,
                color: widget.theme.disabledColor.withAlpha(100),
              );
            },
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'Job Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown(
                              items: _jobItems(),
                              onChange: _onJobChanged,
                              value: widget.appliedFilters.jobId,
                              label: 'Job Position',
                              theme: widget.theme,
                            ),
                          ),
                          if (widget.showHrFilter) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomDropdown(
                                label: 'HR Manager',
                                items: _hrItems(),
                                theme: widget.theme,
                                value: widget.appliedFilters.hrManagerId,
                                onChange: _onHrChanged,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                              onchange: (_) => _applyWithCurrentSelections(),
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
                              onchange: (_) => _applyWithCurrentSelections(),
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
                              onchange: (_) => _applyWithCurrentSelections(),
                              hintText: 'Select start date',
                              labelText: 'From Date',
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextfield(
                              controller: _lastDateToController,
                              keyboardType: TextInputType.datetime,
                              theme: widget.theme,
                              onchange: (_) => _applyWithCurrentSelections(),
                              hintText: 'Select end date',
                              labelText: 'To Date',
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextButton(
                          backgroundColor:
                              widget.theme.colorScheme.error.withOpacity(0.2),
                          onClick: _clearFilters,
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
    final f = widget.appliedFilters;
    return f.jobId != null ||
        (widget.showHrFilter && f.hrManagerId != null) ||
        _postingDateFromController.text.isNotEmpty ||
        _postingDateToController.text.isNotEmpty ||
        _lastDateFromController.text.isNotEmpty ||
        _lastDateToController.text.isNotEmpty;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    final f = widget.appliedFilters;
    if (f.jobId != null) count++;
    if (widget.showHrFilter && f.hrManagerId != null) count++;
    if (_postingDateFromController.text.isNotEmpty) count++;
    if (_postingDateToController.text.isNotEmpty) count++;
    if (_lastDateFromController.text.isNotEmpty) count++;
    if (_lastDateToController.text.isNotEmpty) count++;
    return count;
  }
}
