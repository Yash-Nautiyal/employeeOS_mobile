import 'package:flutter/material.dart';
import 'checkbox.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
    required this.theme,
    required this.allChecked,
    required this.sortAsc,
    required this.onCheckAll,
    required this.onSortDate,
    required this.widths,
  });

  final ThemeData theme;
  final bool allChecked;
  final bool sortAsc;
  final VoidCallback onCheckAll;
  final VoidCallback onSortDate;
  final Map<String, double> widths;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    final labelStyle = theme.textTheme.titleSmall
        ?.copyWith(fontWeight: FontWeight.w700, color: theme.disabledColor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          const SizedBox(width: 10),
          // Checkbox
          CustomCheckbox(
            checked: allChecked,
            onTap: onCheckAll,
            colorScheme: cs,
          ),
          const SizedBox(width: 10),
          // Applicant — widest column
          SizedBox(
            width: widths['applicant'],
            child: Text('Applicant', style: labelStyle),
          ),
          const SizedBox(width: 10),

          // Email
          SizedBox(
            width: widths['email'],
            child: Text('Email', style: labelStyle),
          ),
          const SizedBox(width: 10),

          // Phone
          SizedBox(
            width: widths['phone'],
            child: Text('Phone', style: labelStyle),
          ),
          const SizedBox(width: 10),

          // Status
          SizedBox(
            width: widths['status'],
            child: Text('Status', style: labelStyle),
          ),
          const SizedBox(width: 10),

          // Applied On — sortable
          SizedBox(
            width: widths['appliedOn'],
            child: GestureDetector(
              onTap: onSortDate,
              child: Row(
                children: [
                  Text(
                    'Applied On',
                    style: labelStyle?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    sortAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 13,
                    color: cs.onSurface,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),
          // Resume
          SizedBox(
            width: widths['resume'],
            child: Text('Resume', style: labelStyle),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
