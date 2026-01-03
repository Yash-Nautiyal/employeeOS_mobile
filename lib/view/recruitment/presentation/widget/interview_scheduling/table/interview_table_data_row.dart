import 'package:flutter/material.dart';

class InterviewTableDataRow extends StatefulWidget {
  const InterviewTableDataRow({
    super.key,
    required this.candidate,
    required this.selected,
    required this.widthName,
    required this.widthJobTitle,
    required this.widthApplicationDate,
    required this.widthResume,
    required this.onChanged,
    required this.onMenu,
  });

  final Map<String, String> candidate;
  final bool selected;
  final double widthName, widthJobTitle, widthApplicationDate, widthResume;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<String> onMenu;

  @override
  State<InterviewTableDataRow> createState() => _InterviewTableDataRowState();
}

class _InterviewTableDataRowState extends State<InterviewTableDataRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        color:
            widget.selected ? theme.colorScheme.primary.withOpacity(.05) : null,
      ),
      child: Row(
        children: [
          // Applicant Name cell with checkbox
          SizedBox(
            width: widget.widthName,
            child: Row(
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: widget.onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.candidate['name'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Job Title
          SizedBox(
            width: widget.widthJobTitle,
            child: Text(
              widget.candidate['jobTitle'] ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Application Date
          SizedBox(
            width: widget.widthApplicationDate,
            child: Text(
              widget.candidate['applicationDate'] ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Resume & Actions
          SizedBox(
            width: widget.widthResume,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Resume'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  onSelected: widget.onMenu,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'View', child: Text('View Details')),
                    PopupMenuItem(
                        value: 'Schedule', child: Text('Schedule Interview')),
                    PopupMenuItem(value: 'Reject', child: Text('Reject')),
                  ],
                  child: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

