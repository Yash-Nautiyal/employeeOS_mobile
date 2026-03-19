import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';

class JobPostingFilterPanel extends StatefulWidget {
  const JobPostingFilterPanel({
    super.key,
    required this.initialJobId,
    required this.initialHr,
    required this.initialJoinImmediate,
    required this.initialJoinAfterMonths,
    required this.initialJobType,
    required this.initialDateRange,
    required this.onReset,
    required this.onApply,
  });

  final String initialJobId;
  final String initialHr;
  final bool initialJoinImmediate;
  final bool initialJoinAfterMonths;
  final String initialJobType;
  final DateTimeRange? initialDateRange;
  final VoidCallback onReset;
  final void Function({
    required String jobId,
    required String hr,
    required bool joinImmediate,
    required bool joinAfterMonths,
    required String jobType,
    required DateTimeRange? dateRange,
  }) onApply;

  @override
  State<JobPostingFilterPanel> createState() => _JobPostingFilterPanelState();
}

class _JobPostingFilterPanelState extends State<JobPostingFilterPanel> {
  late final TextEditingController _jobIdController;
  late final TextEditingController _hrController;
  late bool _joinImmediate;
  late bool _joinAfterMonths;
  late String _jobType;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _jobIdController = TextEditingController(text: widget.initialJobId);
    _hrController = TextEditingController(text: widget.initialHr);
    _joinImmediate = widget.initialJoinImmediate;
    _joinAfterMonths = widget.initialJoinAfterMonths;
    _jobType = widget.initialJobType;
    _dateRange = widget.initialDateRange;
  }

  @override
  void dispose() {
    _jobIdController.dispose();
    _hrController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(
      jobId: _jobIdController.text,
      hr: _hrController.text,
      joinImmediate: _joinImmediate,
      joinAfterMonths: _joinAfterMonths,
      jobType: _jobType,
      dateRange: _dateRange,
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
                  bottom:
                      BorderSide(color: theme.dividerColor.withOpacity(0.4)),
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
                        _jobIdController.clear();
                        _hrController.clear();
                        _joinImmediate = false;
                        _joinAfterMonths = false;
                        _jobType = 'All';
                        _dateRange = null;
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
                  _field(
                    theme,
                    controller: _jobIdController,
                    hint: 'Enter job ID...',
                  ),
                  const SizedBox(height: 20),
                  _label(theme, 'HR Filter'),
                  _field(
                    theme,
                    controller: _hrController,
                    hint: 'Enter name or email...',
                  ),
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

  Widget _field(
    ThemeData theme, {
    required TextEditingController controller,
    required String hint,
  }) {
    return CustomTextfield(
      controller: controller,
      onchange: (_) => _apply(),
      keyboardType: TextInputType.text,
      theme: theme,
      hintText: hint,
    );
  }
}
