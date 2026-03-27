import 'dart:convert';
import 'dart:ui';

import 'package:employeeos/core/index.dart'
    show AppPallete, CustomDropdown, CustomTextButton, CustomTextfield;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/index.dart';
import '../../../../domain/index.dart' show GetJobDepartmentUseCase;
import '../components/quill/tool_bar.dart';
import 'detail_section.dart';

class AddJobPostingPage extends StatefulWidget {
  const AddJobPostingPage({super.key});

  @override
  State<AddJobPostingPage> createState() => _AddJobPostingPageState();
}

class _AddJobPostingPageState extends State<AddJobPostingPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Details
  final _jobTitleController = TextEditingController();
  String? _selectedDepartment;
  late QuillController _descriptionController;
  List<String> _departments = const [];
  // Qualifications (collapsible)
  final _qualificationsController = TextEditingController();

  // Additional fields
  final _locationController = TextEditingController();
  final _positionsController = TextEditingController(text: '1');
  final _lastDateController = TextEditingController();
  final _ctcRangeController = TextEditingController();
  final _postedByNameController = TextEditingController();
  final _postedByEmailController = TextEditingController();

  String _joiningType = 'Immediate';
  bool _isInternship = false;
  bool _isDescriptionFullScreenOpen = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = QuillController.basic();
    _postedByNameController.text = _postedByName;
    _postedByEmailController.text = _postedByEmail;
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final repo = JobPostingRepositoryImpl(JobPostingMockDatasource.instance);
    final departments = await GetJobDepartmentUseCase(repo).call();
    if (!mounted) return;
    setState(() => _departments = departments);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _qualificationsController.dispose();
    _locationController.dispose();
    _positionsController.dispose();
    _lastDateController.dispose();
    _ctcRangeController.dispose();
    _postedByNameController.dispose();
    _postedByEmailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _postedByName {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return '—';
    final name = user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
    return name?.toString() ?? user.email ?? '—';
  }

  String get _postedByEmail {
    return Supabase.instance.client.auth.currentUser?.email ?? '—';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final department = (_selectedDepartment ?? '').trim();

    // For now, this screen writes into the in-memory datasource.
    final descriptionJson = jsonEncode(
      _descriptionController.document.toDelta().toJson(),
    );

    final job = JobPostingModel(
      id: 'job-mock-${DateTime.now().microsecondsSinceEpoch}',
      title: _jobTitleController.text.trim(),
      department: department,
      description: descriptionJson,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      positions: int.tryParse(_positionsController.text.trim()) ?? 1,
      lastDateToApply: _parseDateFromField(_lastDateController.text.trim()),
      joiningType: _joiningType,
      isInternship: _isInternship,
      ctcRange: _ctcRangeController.text.trim().isEmpty
          ? null
          : _ctcRangeController.text.trim(),
      postedByName: _postedByNameController.text.trim(),
      postedByEmail: _postedByEmailController.text.trim(),
      createdAt: DateTime.now(),
    );

    JobPostingMockDatasource.instance.add(job);
    Navigator.of(context).pop(true);
  }

  DateTime? _parseDateFromField(String text) {
    if (text.isEmpty) return null;
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;
    final parts = text.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  void _openDescriptionFullScreen() {
    setState(() => _isDescriptionFullScreenOpen = true);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Description'),
            ),
            body: Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: theme.scaffoldBackgroundColor,
                    child: ToolBar(
                      controller: _descriptionController,
                      theme: theme,
                      openDescriptionFullScreen: () =>
                          Navigator.of(context).pop(),
                      isFullScreen: true,
                    )),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                          top: BorderSide(
                              color:
                                  theme.dividerColor.withValues(alpha: 0.5))),
                    ),
                    child: QuillEditor.basic(
                      controller: _descriptionController,
                      config: const QuillEditorConfig(
                        padding: EdgeInsets.zero,
                        placeholder:
                            'Enter description (e.g. responsibilities, requirements...)',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    )
        .then((_) {
      if (mounted) setState(() => _isDescriptionFullScreenOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Add Job Posting', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withOpacity(.2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: [
            DetailSection(
              theme: theme,
              jobTitleController: _jobTitleController,
              descriptionController: _descriptionController,
              openDescriptionFullScreen: _openDescriptionFullScreen,
              isFullScreen: false,
              isDescriptionFullScreenOpen: _isDescriptionFullScreenOpen,
              departmentOptions: _departments,
              selectedDepartment: _selectedDepartment,
              allowAddNewDepartment: true,
              onDepartmentChanged: (v) {
                setState(() {
                  _selectedDepartment = v;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildAdditionalFieldsSection(theme),
            const SizedBox(height: 32),
            _buildSubmitButton(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFieldsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: theme.shadowColor, spreadRadius: 0, blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: _locationController,
            theme: theme,
            hintText: 'Enter location...',
            keyboardType: TextInputType.streetAddress,
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Positions',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: _positionsController,
            theme: theme,
            hintText: '1',
            keyboardType: TextInputType.number,
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Last Date to Apply',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: _lastDateController,
            theme: theme,
            hintText: 'Tap to select date',
            keyboardType: TextInputType.datetime,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Joining Type',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomDropdown(
            theme: theme,
            label: 'Joining Type',
            value: _joiningType,
            items: ['Immediate', 'Notice Period', 'Flexible']
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChange: (v) => setState(() => _joiningType = v as String),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _isInternship,
                  onChanged: (v) => setState(() => _isInternship = v),
                ),
              ),
              const SizedBox(width: 8),
              Text('Is this an internship?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Expected CTC Range',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: _ctcRangeController,
            theme: theme,
            hintText: 'e.g., ₹5-7 LPA',
            keyboardType: TextInputType.text,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('₹',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.disabledColor)),
            ),
            onchange: (_) {},
          ),
          const SizedBox(height: 6),
          Text('Format: ₹X-Y per Month',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.disabledColor)),
          const SizedBox(height: 16),
          Text('Posted By',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _postedByNameController,
            readOnly: true,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.colorScheme.tertiary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              hintText: 'Posted by',
              hintStyle: theme.textTheme.bodyMedium,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: AppPallete.grey500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Email',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _postedByEmailController,
            readOnly: true,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.colorScheme.tertiary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              hintText: 'Email',
              hintStyle: theme.textTheme.bodyMedium,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: AppPallete.grey500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomTextButton(
        onClick: _submit,
        backgroundColor: theme.colorScheme.tertiary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save, size: 20, color: theme.scaffoldBackgroundColor),
            const SizedBox(width: 8),
            Text('Save Job Posting',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.scaffoldBackgroundColor)),
          ],
        ),
      ),
    );
  }
}
