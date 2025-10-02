import 'package:employeeos/core/common/actions/date_time_actions.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// UI component for date range filtering
/// This component is now purely UI-focused and uses the controller for state management
class FilterDateRangeWidget extends StatelessWidget {
  final ThemeData theme;

  const FilterDateRangeWidget({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FilterControllerProvider.of(context);
    final dateRange = controller.filterState.dateRangeFilter.dateRange;
    final isActive = controller.filterState.dateRangeFilter.isActive;

    return InkWell(
      onTap: () => _showDateRangeDialog(context, controller),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.dividerColor.withOpacity(0.3),
          ),
          color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/ic-calender.svg',
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 8),
            Text(
              dateRange != null ? formatDateRange(dateRange) : 'Date Range',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.tertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangeDialog(
    BuildContext context,
    FileManagerFilterController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DateRangeDialog(
        selectedDateRange: controller.filterState.dateRangeFilter.dateRange,
        theme: theme,
        controller: controller,
      ),
    );
  }
}

/// Dialog widget for date range selection
class _DateRangeDialog extends StatefulWidget {
  final DateTimeRange? selectedDateRange;
  final ThemeData theme;
  final FileManagerFilterController controller;

  const _DateRangeDialog({
    this.selectedDateRange,
    required this.theme,
    required this.controller,
  });

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  DateTimeRange? _localSelectedDateRange;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;

  @override
  void initState() {
    super.initState();
    _localSelectedDateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select Date Range', style: widget.theme.textTheme.titleLarge),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-mingcute_close-line.svg',
              color: widget.theme.colorScheme.error,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Selection Buttons
            Row(
              children: [
                Expanded(
                  child: _DateSelectorButton(
                    label: 'Start Date',
                    date: _tempStartDate ?? _localSelectedDateRange?.start,
                    theme: widget.theme,
                    onTap: () => _selectStartDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateSelectorButton(
                    label: 'End Date',
                    date: _tempEndDate ?? _localSelectedDateRange?.end,
                    theme: widget.theme,
                    onTap: () => _selectEndDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick date range options
            _QuickDateOptions(
              theme: widget.theme,
              selectedRange: _localSelectedDateRange,
              tempStartDate: _tempStartDate,
              tempEndDate: _tempEndDate,
              onRangeSelected: (range) {
                setState(() {
                  _localSelectedDateRange = range;
                  _tempStartDate = range.start;
                  _tempEndDate = range.end;
                });
              },
            ),
            // Selected date range display
            if (_localSelectedDateRange != null ||
                (_tempStartDate != null && _tempEndDate != null))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _SelectedRangeDisplay(
                  theme: widget.theme,
                  range: _localSelectedDateRange,
                  tempStartDate: _tempStartDate,
                  tempEndDate: _tempEndDate,
                ),
              ),
          ],
        ),
      ),
      actions: [
        CustomTextButton(
          child: Text('Clear', style: widget.theme.textTheme.labelLarge),
          onClick: () {
            widget.controller.clearDateRangeFilter();
            Navigator.of(context).pop();
          },
        ),
        CustomTextButton(
          onClick: () {
            DateTimeRange? rangeToApply;

            if (_tempStartDate != null && _tempEndDate != null) {
              rangeToApply = DateTimeRange(
                start: _tempStartDate!,
                end: _tempEndDate!,
              );
            } else if (_localSelectedDateRange != null) {
              rangeToApply = _localSelectedDateRange;
            }

            widget.controller.updateDateRangeFilter(rangeToApply);
            Navigator.of(context).pop();
          },
          backgroundColor: widget.theme.colorScheme.tertiary,
          child: Text(
            'Apply',
            style: widget.theme.textTheme.labelLarge?.copyWith(
              color: widget.theme.scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _tempStartDate ?? _localSelectedDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: widget.theme.copyWith(
            colorScheme: widget.theme.colorScheme.copyWith(
              primary: widget.theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _tempStartDate = date;
        // If end date is before start date, clear it
        if (_tempEndDate != null && _tempEndDate!.isBefore(date)) {
          _tempEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempEndDate ??
          _localSelectedDateRange?.end ??
          (_tempStartDate ?? DateTime.now()),
      firstDate: _tempStartDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: widget.theme.copyWith(
            colorScheme: widget.theme.colorScheme.copyWith(
              primary: widget.theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _tempEndDate = date;
      });
    }
  }
}

/// Date selector button widget
class _DateSelectorButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ThemeData theme;
  final VoidCallback onTap;

  const _DateSelectorButton({
    required this.label,
    required this.date,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: TextEditingController(
        text: date != null ? formatDate(date!) : '',
      ),
      readOnly: true,
      onTap: onTap,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: date != null
            ? theme.colorScheme.primary
            : theme.colorScheme.tertiary,
        fontWeight: date != null ? FontWeight.w800 : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Quick date options widget
class _QuickDateOptions extends StatelessWidget {
  final ThemeData theme;
  final DateTimeRange? selectedRange;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;
  final Function(DateTimeRange) onRangeSelected;

  const _QuickDateOptions({
    required this.theme,
    required this.selectedRange,
    required this.tempStartDate,
    required this.tempEndDate,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final quickOptions = [
      ('Today', DateTimeRange(start: today, end: today)),
      (
        'Yesterday',
        DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today.subtract(const Duration(days: 1)),
        )
      ),
      (
        'Last 7 days',
        DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        )
      ),
      (
        'Last 30 days',
        DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        )
      ),
      (
        'This month',
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        )
      ),
      (
        'Last month',
        DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        )
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Options',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickOptions.map((option) {
            final isSelected = _isRangeEqual(selectedRange, option.$2) ||
                _isRangeEqual(
                  tempStartDate != null && tempEndDate != null
                      ? DateTimeRange(start: tempStartDate!, end: tempEndDate!)
                      : null,
                  option.$2,
                );

            return InkWell(
              onTap: () => onRangeSelected(option.$2),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withAlpha(35)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  option.$1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isRangeEqual(DateTimeRange? range1, DateTimeRange range2) {
    if (range1 == null) return false;
    return range1.start.year == range2.start.year &&
        range1.start.month == range2.start.month &&
        range1.start.day == range2.start.day &&
        range1.end.year == range2.end.year &&
        range1.end.month == range2.end.month &&
        range1.end.day == range2.end.day;
  }
}

/// Selected range display widget
class _SelectedRangeDisplay extends StatelessWidget {
  final ThemeData theme;
  final DateTimeRange? range;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;

  const _SelectedRangeDisplay({
    required this.theme,
    required this.range,
    required this.tempStartDate,
    required this.tempEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/ic-calender.svg',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getDisplayText(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    if (tempStartDate != null && tempEndDate != null) {
      return formatDateRange(
          DateTimeRange(start: tempStartDate!, end: tempEndDate!));
    }
    if (range != null) {
      return formatDateRange(range!);
    }
    return '';
  }
}
