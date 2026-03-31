import 'package:employeeos/core/index.dart'
    show
        CustomDialog,
        CustomDropdown,
        CustomTextButton,
        CustomTextfield,
        UserInfoEntity,
        UserInfoService;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../domain/index.dart' show InterviewRound, InterviewRoundLabel;
import 'schedule_interview_dialogs.dart';

class ScheduleInterviewFormDialog extends StatefulWidget {
  const ScheduleInterviewFormDialog({
    super.key,
    required this.theme,
    required this.userInfoService,
    required this.round,
  });

  final ThemeData theme;
  final UserInfoService userInfoService;
  final InterviewRound round;

  @override
  State<ScheduleInterviewFormDialog> createState() =>
      _ScheduleInterviewFormDialogState();
}

class _ScheduleInterviewFormDialogState
    extends State<ScheduleInterviewFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late TimeOfDay _time;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  List<UserInfoEntity>? _users;
  String? _loadError;
  UserInfoEntity? _interviewer;
  UserInfoEntity? _assignedBy;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _time = TimeOfDay(hour: now.hour, minute: now.minute);
    _dateController = TextEditingController(text: _formatDateForField(_date));
    _timeController = TextEditingController(text: _formatTime(_time));
    _loadHrUsers();
  }

  String _formatDateForField(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _loadHrUsers() async {
    try {
      final list = await widget.userInfoService.fetchHrUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _displayName(UserInfoEntity u) {
    final n = u.fullName.trim();
    if (n.isNotEmpty) return n;
    final e = u.email.trim();
    if (e.isNotEmpty) return e;
    return u.id;
  }

  String _formatTime(TimeOfDay t) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    return DateFormat.jm().format(dt);
  }

  void _onDateTextChanged(String v) {
    final parts = v.split('/');
    if (parts.length != 3) return;
    final d = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    final y = int.tryParse(parts[2].trim());
    if (d == null || m == null || y == null) return;
    if (m < 1 || m > 12 || d < 1 || d > 31) return;
    setState(() => _date = DateTime(y, m, d));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked == null) return;
    setState(() {
      _time = picked;
      _timeController.text = _formatTime(picked);
    });
  }

  void _submit() {
    final users = _users;
    if (users == null || users.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;
    final iv = _interviewer;
    final ab = _assignedBy;
    if (iv == null || ab == null) return;

    final start = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final end = start.add(const Duration(hours: 1));

    Navigator.of(context).pop(
      ScheduleInterviewFormResult(
        startLocal: start,
        endLocal: end,
        interviewer: iv,
        assignedBy: ab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Schedule ${widget.round.label} Interview';

    if (_loadError != null) {
      return CustomDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: widget.theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(_loadError!),
              const SizedBox(height: 16),
              CustomTextButton(
                onClick: () => Navigator.of(context).pop(),
                child: Text('Close', style: widget.theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
      );
    }

    if (_users == null) {
      return CustomDialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: widget.theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 16),
              CustomTextButton(
                onClick: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: widget.theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
      );
    }

    final users = _users!;
    if (users.isEmpty) {
      return CustomDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: widget.theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'No HR users found in user_info. Check roles (hr/admin).',
              ),
              const SizedBox(height: 16),
              CustomTextButton(
                onClick: () => Navigator.of(context).pop(),
                child: Text('Close', style: widget.theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
      );
    }

    return CustomDialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: widget.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      CustomTextfield(
                        theme: widget.theme,
                        controller: _dateController,
                        keyboardType: TextInputType.datetime,
                        hintText: '',
                        labelText: 'Interview date',
                        alwaysFloatingLabel: true,
                        onchange: (v) => _onDateTextChanged(v.toString()),
                        initialDateForPicker: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        theme: widget.theme,
                        controller: _timeController,
                        keyboardType: TextInputType.text,
                        hintText: '',
                        labelText: 'Interview time',
                        alwaysFloatingLabel: true,
                        readOnly: true,
                        onFieldTap: _pickTime,
                        onchange: (_) {},
                        suffixIcon: IconButton(
                          onPressed: _pickTime,
                          icon: SvgPicture.asset(
                            'assets/icons/common/solid/ic-solar_clock-circle-bold.svg',
                            colorFilter: ColorFilter.mode(
                              widget.theme.disabledColor,
                              BlendMode.srcIn,
                            ),
                            width: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomDropdown(
                        theme: widget.theme,
                        value: _interviewer,
                        label: 'Interviewer',
                        items: users
                            .map(
                              (u) => DropdownMenuItem<UserInfoEntity>(
                                value: u,
                                child: Text(_displayName(u)),
                              ),
                            )
                            .toList(),
                        onChange: (v) =>
                            setState(() => _interviewer = v as UserInfoEntity),
                        validator: (v) =>
                            v == null ? 'Select an interviewer' : null,
                      ),
                      const SizedBox(height: 12),
                      CustomDropdown(
                        theme: widget.theme,
                        value: _assignedBy,
                        label: 'Assigned by',
                        items: users
                            .map(
                              (u) => DropdownMenuItem<UserInfoEntity>(
                                value: u,
                                child: Text(_displayName(u)),
                              ),
                            )
                            .toList(),
                        onChange: (v) =>
                            setState(() => _assignedBy = v as UserInfoEntity),
                        validator: (v) =>
                            v == null ? 'Select assigned by' : null,
                      ),
                      const SizedBox(height: 14),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget
                              .theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'AFTER THIS YOU WILL BE REDIRECTED TO CALENDAR EVENT SCHEDULING',
                            textAlign: TextAlign.center,
                            style: widget.theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextButton(
                  onClick: () => Navigator.of(context).pop(),
                  child:
                      Text('Cancel', style: widget.theme.textTheme.labelLarge),
                ),
                const SizedBox(width: 8),
                CustomTextButton(
                  backgroundColor: widget.theme.colorScheme.tertiary,
                  onClick: _submit,
                  child: Text(
                    'Continue',
                    style: widget.theme.textTheme.labelLarge?.copyWith(
                      color: widget.theme.scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
