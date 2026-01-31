// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/index.dart' show formatDateRange;

class SelectedRangeDisplay extends StatelessWidget {
  final ThemeData theme;
  final DateTimeRange? range;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;

  const SelectedRangeDisplay({
    super.key,
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
