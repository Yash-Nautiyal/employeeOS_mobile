import 'package:employeeos/core/index.dart' show CustomDropdown;
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
import 'package:flutter/material.dart';

/// Unique HR labels for filter dropdowns (postings + applications share this).
List<String> distinctRecruitmentHrOptions(Iterable<JobPosting> jobs) {
  final set = <String>{};
  for (final j in jobs) {
    final name = j.postedByName.trim();
    if (name.isNotEmpty) {
      set.add(name);
    } else {
      final email = j.postedByEmail.trim();
      if (email.isNotEmpty) set.add(email);
    }
  }
  return (set.toList()..sort());
}

class JobPostingFilterPanel extends StatefulWidget {
  const JobPostingFilterPanel({
    super.key,
    required this.jobs,
    required this.initialJobId,
    required this.initialHr,
    required this.initialJoinImmediate,
    required this.initialJoinAfterMonths,
    required this.initialJobType,
    required this.initialDateRange,
    required this.onReset,
    required this.onApply,
    this.showApplicationStatusFilter = false,
    this.initialApplicationStatus = '',
  });

  final List<JobPosting> jobs;
  final String initialJobId;
  final String initialHr;
  final bool initialJoinImmediate;
  final bool initialJoinAfterMonths;
  final String initialJobType;
  final DateTimeRange? initialDateRange;

  /// When true (job applications screen), shows **Application status** dropdown.
  final bool showApplicationStatusFilter;
  final String initialApplicationStatus;
  final VoidCallback onReset;
  final void Function({
    required String jobId,
    required String hr,
    required bool joinImmediate,
    required bool joinAfterMonths,
    required String jobType,
    required DateTimeRange? dateRange,
    String applicationStatus,
  }) onApply;

  @override
  State<JobPostingFilterPanel> createState() => _JobPostingFilterPanelState();
}

class _JobPostingFilterPanelState extends State<JobPostingFilterPanel> {
  late String _selectedHr;
  late bool _joinImmediate;
  late bool _joinAfterMonths;
  late String _jobType;
  DateTimeRange? _dateRange;

  late String _selectedJobId;
  late String _applicationStatus;

  @override
  void initState() {
    super.initState();
    _selectedJobId = widget.initialJobId.trim();
    _selectedHr = widget.initialHr.trim();
    _joinImmediate = widget.initialJoinImmediate;
    _joinAfterMonths = widget.initialJoinAfterMonths;
    _jobType = widget.initialJobType;
    _dateRange = widget.initialDateRange;
    _applicationStatus = widget.initialApplicationStatus.trim();
  }

  void _apply() {
    widget.onApply(
      jobId: _selectedJobId,
      hr: _selectedHr,
      joinImmediate: _joinImmediate,
      joinAfterMonths: _joinAfterMonths,
      jobType: _jobType,
      dateRange: _dateRange,
      applicationStatus:
          widget.showApplicationStatusFilter ? _applicationStatus : '',
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _apply();
    }
  }

  String _formatRange() {
    if (_dateRange == null) return 'Select date range';
    final s = _dateRange!.start;
    final e = _dateRange!.end;
    return '${s.day.toString().padLeft(2, '0')}/${s.month.toString().padLeft(2, '0')}/${s.year}'
        ' - '
        '${e.day.toString().padLeft(2, '0')}/${e.month.toString().padLeft(2, '0')}/${e.year}';
  }

  Widget _jobIdDropdown(ThemeData theme) {
    final jobs = widget.jobs;
    final ids = jobs.map((j) => j.id).toSet().toList()..sort();

    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: '',
        child: Text('All jobs'),
      ),
      ...ids.map((id) {
        final j = jobs.firstWhere((e) => e.id == id);
        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            '${j.id} — ${j.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
    ];

    var value = _selectedJobId;
    if (value.isNotEmpty && !ids.contains(value)) {
      items.add(
        DropdownMenuItem<String>(
          value: value,
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    if (!items.any((e) => e.value == value)) {
      value = '';
    }

    return SizedBox(
      height: 52,
      child: CustomDropdown(
        value: value,
        theme: theme,
        isSearchable: true,
        onChange: (dynamic v) {
          if (v == null) return;
          setState(() => _selectedJobId = v as String);
          _apply();
        },
        label: '',
        items: items,
      ),
    );
  }

  Widget _hrDropdown(ThemeData theme) {
    final hrOptions = distinctRecruitmentHrOptions(widget.jobs);

    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: '',
        child: Text('All HR'),
      ),
      ...hrOptions.map(
        (h) => DropdownMenuItem<String>(
          value: h,
          child: Text(
            h,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    var value = _selectedHr;
    if (value.isNotEmpty && !hrOptions.contains(value)) {
      items.add(
        DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    if (!items.any((e) => e.value == value)) {
      value = '';
    }

    return SizedBox(
      height: 52,
      child: CustomDropdown(
        value: value,
        theme: theme,
        isSearchable: true,
        onChange: (dynamic v) {
          if (v == null) return;
          setState(() => _selectedHr = v as String);
          _apply();
        },
        label: '',
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.4)),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text('Filters', style: theme.textTheme.displaySmall),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Reset',
                    onPressed: () {
                      setState(() {
                        _selectedJobId = '';
                        _selectedHr = '';
                        _joinImmediate = false;
                        _joinAfterMonths = false;
                        _jobType = 'All';
                        _dateRange = null;
                        _applicationStatus = '';
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, 'Job ID'),
                  _jobIdDropdown(theme),
                  const SizedBox(height: 20),
                  _label(theme, 'HR'),
                  _hrDropdown(theme),
                  const SizedBox(height: 20),
                  _label(theme, 'Joining Type'),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('immediate'),
                    value: _joinImmediate,
                    onChanged: (v) {
                      setState(() => _joinImmediate = v ?? false);
                      _apply();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('after_months'),
                    value: _joinAfterMonths,
                    onChanged: (v) {
                      setState(() => _joinAfterMonths = v ?? false);
                      _apply();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  _label(theme, 'Job Type'),
                  SizedBox(
                    height: 52,
                    child: CustomDropdown(
                      value: _jobType,
                      theme: theme,
                      onChange: (v) {
                        if (v == null) return;
                        setState(() => _jobType = v);
                        _apply();
                      },
                      label: '',
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(
                            value: 'Internship', child: Text('Internship')),
                        DropdownMenuItem(
                            value: 'Full-time', child: Text('Full-time')),
                      ],
                    ),
                  ),
                  if (widget.showApplicationStatusFilter) ...[
                    const SizedBox(height: 20),
                    _label(theme, 'Application status'),
                    SizedBox(
                      height: 52,
                      child: CustomDropdown(
                        value: _applicationStatus.isEmpty
                            ? ''
                            : _applicationStatus,
                        theme: theme,
                        onChange: (v) {
                          if (v == null) return;
                          setState(() => _applicationStatus = v as String);
                          _apply();
                        },
                        label: '',
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'shortlisted',
                            child: Text('Shortlisted'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _label(theme, 'Date Range'),
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatRange(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
