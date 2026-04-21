// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/common/components/ui/custom_textbutton.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class InterviewTableDataRow extends StatefulWidget {
  const InterviewTableDataRow({
    super.key,
    required this.candidate,
    required this.selected,
    required this.widthName,
    required this.widthJobTitle,
    required this.widthApplicationDate,
    required this.widthResume,
    this.showResume = true,
    this.widthRejectedRound = 0,
    this.showRejectedRound = false,
    required this.onChanged,
    required this.onMenu,
  });

  final InterviewCandidate candidate;
  final bool selected;
  final double widthName, widthJobTitle, widthApplicationDate, widthResume;
  final bool showResume;
  final double widthRejectedRound;
  final bool showRejectedRound;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<String> onMenu;

  @override
  State<InterviewTableDataRow> createState() => _InterviewTableDataRowState();
}

class _InterviewTableDataRowState extends State<InterviewTableDataRow> {
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('d MMM yyyy');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
      ),
      child: Row(
        children: [
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
                    widget.candidate.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          SizedBox(
            width: widget.widthJobTitle,
            child: Text(
              widget.candidate.jobTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: widget.widthApplicationDate,
            child: Text(
              _dateFormat.format(widget.candidate.applicationDate),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.showResume)
            SizedBox(
              width: widget.widthResume,
              child: Row(
                children: [
                  CustomTextButton(
                    padding: 0,
                    onClick: () => widget.onMenu('download'),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/common/solid/ic-mingcute-download-line.svg',
                          width: 20,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        Text('Resume', style: theme.textTheme.labelLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (widget.showRejectedRound)
            SizedBox(
              width: widget.widthRejectedRound,
              child: Text(
                widget.candidate.rejectedFromRound?.label ?? '—',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
