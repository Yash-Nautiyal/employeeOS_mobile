// ignore_for_file: deprecated_member_use

import 'package:employeeos/core/index.dart' show CustomDropdown;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InterviewFilterPanel extends StatefulWidget {
  final String selectedJob;
  final String selectedInterviewer;
  final String selectedStatus;
  final DateTimeRange? selectedDateRange;
  final List<String> jobOptions;
  final List<String> interviewerOptions;
  final List<String> statusOptions;
  final VoidCallback onReset;
  final void Function({
    required String job,
    required String interviewer,
    required String status,
    required DateTimeRange? range,
  }) onApply;

  /// When set, the job filter is read-only (scheduling scoped to one job).
  final String? lockedJobTitle;

  const InterviewFilterPanel({
    super.key,
    required this.selectedJob,
    required this.selectedInterviewer,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.jobOptions,
    required this.interviewerOptions,
    required this.statusOptions,
    required this.onReset,
    required this.onApply,
    this.lockedJobTitle,
  });

  @override
  State<InterviewFilterPanel> createState() => _InterviewFilterPanelState();
}

class _InterviewFilterPanelState extends State<InterviewFilterPanel> {
  late String _job;
  late String _interviewer;
  late String _status;
  DateTimeRange? _range;

  void _apply() {
    widget.onApply(
      job: _job,
      interviewer: _interviewer,
      status: _status,
      range: _range,
    );
  }

  @override
  void initState() {
    super.initState();
    _job = widget.selectedJob;
    _interviewer = widget.selectedInterviewer;
    _status = widget.selectedStatus;
    _range = widget.selectedDateRange;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
      _apply();
    }
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Select date range';
    final fmt = DateFormat('d MMM yyyy');
    return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: theme.dividerColor.withOpacity(0.3))),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.displaySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Reset',
                    onPressed: () {
                      setState(() {
                        _job = widget.lockedJobTitle != null
                            ? widget.selectedJob
                            : widget.jobOptions.first;
                        _interviewer = widget.interviewerOptions.first;
                        _status = widget.statusOptions.first;
                        _range = null;
                      });
                      widget.onReset();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(theme, 'Job ID'),
                if (widget.lockedJobTitle != null)
                  Container(
                    height: 52,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(
                      widget.lockedJobTitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  _buildDropdown(
                    theme: theme,
                    value: _job,
                    items: widget.jobOptions,
                    onChanged: (v) {
                      setState(() => _job = v ?? _job);
                      _apply();
                    },
                  ),
                const SizedBox(height: 20),
                _buildLabel(theme, 'Interviewer'),
                _buildDropdown(
                  theme: theme,
                  value: _interviewer,
                  items: widget.interviewerOptions,
                  onChanged: (v) {
                    setState(() => _interviewer = v ?? _interviewer);
                    _apply();
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel(theme, 'Status'),
                _buildDropdown(
                  theme: theme,
                  value: _status,
                  items: widget.statusOptions,
                  onChanged: (v) {
                    setState(() => _status = v ?? _status);
                    _apply();
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel(theme, 'Interview Date'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickRange,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatRange(_range),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 52,
      child: CustomDropdown(
        value: value,
        theme: theme,
        onChange: onChanged,
        label: '',
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
      ),
    );
  }
}
