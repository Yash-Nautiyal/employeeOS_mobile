import 'package:employeeos/core/index.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
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
  });

  @override
  State<InterviewFilterPanel> createState() => _InterviewFilterPanelState();
}

class _InterviewFilterPanelState extends State<InterviewFilterPanel> {
  late String _job;
  late String _interviewer;
  late String _status;
  DateTimeRange? _range;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Reset',
                  onPressed: () {
                    setState(() {
                      _job = widget.jobOptions.first;
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
            const SizedBox(height: 16),
            _buildLabel(theme, 'Job ID'),
            _buildDropdown(
              theme: theme,
              value: _job,
              items: widget.jobOptions,
              onChanged: (v) => setState(() => _job = v ?? _job),
            ),
            const SizedBox(height: 20),
            _buildLabel(theme, 'Interviewer'),
            _buildDropdown(
              theme: theme,
              value: _interviewer,
              items: widget.interviewerOptions,
              onChanged: (v) =>
                  setState(() => _interviewer = v ?? _interviewer),
            ),
            const SizedBox(height: 20),
            _buildLabel(theme, 'Status'),
            _buildDropdown(
              theme: theme,
              value: _status,
              items: widget.statusOptions,
              onChanged: (v) => setState(() => _status = v ?? _status),
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
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _job = widget.jobOptions.first;
                        _interviewer = widget.interviewerOptions.first;
                        _status = widget.statusOptions.first;
                        _range = null;
                      });
                      widget.onReset();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        job: _job,
                        interviewer: _interviewer,
                        status: _status,
                        range: _range,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
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
