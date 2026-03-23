// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/common/actions/date_time_actions.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../index.dart' show DateSelectorButton, QuickDateOptions;

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
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              dateRange != null ? formatDateRange(dateRange) : 'Date Range',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.onSurface,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Date Range',
            style: widget.theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-mingcute_close-line.svg',
              color: widget.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Selection Buttons
                Row(
                  children: [
                    Expanded(
                      child: DateSelectorButton(
                        label: 'Start Date',
                        date: _tempStartDate ?? _localSelectedDateRange?.start,
                        theme: widget.theme,
                        onTap: () => _selectStartDate(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DateSelectorButton(
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
                QuickDateOptions(
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
                // if (_localSelectedDateRange != null ||
                //     (_tempStartDate != null && _tempEndDate != null))
                //   Padding(
                //     padding: const EdgeInsets.only(top: 16),
                //     child: SelectedRangeDisplay(
                //       theme: widget.theme,
                //       range: _localSelectedDateRange,
                //       tempStartDate: _tempStartDate,
                //       tempEndDate: _tempEndDate,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        CustomTextButton(
          padding: 0,
          child: Text('Clear', style: widget.theme.textTheme.labelLarge),
          onClick: () {
            widget.controller.clearDateRangeFilter();
            Navigator.of(context).pop();
          },
        ),
        CustomTextButton(
          padding: 0,
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
          backgroundColor: widget.theme.colorScheme.onSurface,
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
        return child!;
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
