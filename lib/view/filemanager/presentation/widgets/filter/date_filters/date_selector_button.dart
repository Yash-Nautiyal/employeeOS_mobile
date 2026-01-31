import 'package:flutter/material.dart';

import '../../../../../../core/index.dart' show formatDate;

class DateSelectorButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ThemeData theme;
  final VoidCallback onTap;

  const DateSelectorButton({
    super.key,
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
