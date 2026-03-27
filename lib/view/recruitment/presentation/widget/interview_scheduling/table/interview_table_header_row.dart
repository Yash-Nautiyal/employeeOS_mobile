import 'package:flutter/material.dart';

class InterviewTableHeaderRow extends StatelessWidget {
  const InterviewTableHeaderRow({
    super.key,
    required this.widthName,
    required this.widthJobTitle,
    required this.widthApplicationDate,
    required this.widthResume,
    this.widthRejectedRound = 0,
    this.showRejectedRound = false,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    required this.selectedCount,
    required this.onClear,
  });

  final double widthName, widthJobTitle, widthApplicationDate, widthResume;
  final double widthRejectedRound;
  final bool showRejectedRound;
  final bool? checkboxValue; // tri-state
  final ValueChanged<bool?> onCheckboxChanged;
  final int selectedCount;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle head = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: widthName,
            child: Row(
              children: [
                Checkbox(
                  value: checkboxValue,
                  tristate: true,
                  onChanged: onCheckboxChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                Text('Applicant Name', style: head),
              ],
            ),
          ),
          SizedBox(width: widthJobTitle, child: Text('Job Title', style: head)),
          SizedBox(
              width: widthApplicationDate,
              child: Text('Application Date', style: head)),
          SizedBox(width: widthResume, child: Text('Resume', style: head)),
          if (showRejectedRound)
            SizedBox(
              width: widthRejectedRound,
              child: Text('Rejected in round', style: head),
            ),
        ],
      ),
    );
  }
}
