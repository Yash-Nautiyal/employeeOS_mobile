import 'package:flutter/material.dart';

class QuickDateOptions extends StatelessWidget {
  final ThemeData theme;
  final DateTimeRange? selectedRange;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;
  final Function(DateTimeRange) onRangeSelected;

  const QuickDateOptions({
    super.key,
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

    return Row(
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                            ? DateTimeRange(
                                start: tempStartDate!, end: tempEndDate!)
                            : null,
                        option.$2,
                      );

                  return InkWell(
                    onTap: () => onRangeSelected(option.$2),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
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
