import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../components/quill/tool_bar.dart';
import '../add_posting/detail_section.dart';

import 'package:employeeos/core/index.dart'
    show AppPallete, CustomDropdown, CustomTextButton, CustomTextfield;
import '../../../../data/index.dart' show JobPostingModel;
import '../../../../domain/index.dart' show JobPosting;
import '../../../utils/quill/quill_description_codec.dart';
import '../../injection/job_posting_injection.dart';

class JobEditingPage extends StatefulWidget {
  final JobPosting job;
  final VoidCallback? onJobUpdated;

  const JobEditingPage({
    super.key,
    required this.job,
    this.onJobUpdated,
  });

  @override
  State<JobEditingPage> createState() => _JobEditingPageState();
}

class _JobEditingPageState extends State<JobEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _jobTitleController = TextEditingController();
  List<String> _departments = const [];
  String? _selectedDepartment;
  late QuillController _descriptionController;

  final _qualificationsController = TextEditingController();
  final _locationController = TextEditingController();
  late TextEditingController _positionsController;
  final _lastDateController = TextEditingController();
  final _ctcRangeController = TextEditingController();
  final _postedByNameController = TextEditingController();
  final _postedByEmailController = TextEditingController();

  late String _joiningType;
  late bool _isInternship;
  bool _isDescriptionFullScreenOpen = false;

  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _jobTitleController.text = j.title;
    _selectedDepartment = j.department;
    _locationController.text = j.location ?? '';
    _positionsController = TextEditingController(text: '${j.positions}');
    _lastDateController.text = _formatDateForField(j.lastDateToApply);
    _joiningType = j.joiningType;
    _isInternship = j.isInternship;
    _ctcRangeController.text = j.ctcRange ?? '';
    _postedByNameController.text = j.postedByName;
    _postedByEmailController.text = j.postedByEmail;

    if (j.description != null && j.description!.trim().isNotEmpty) {
      final doc = QuillDescriptionCodec.decodeToDocument(j.description);
      _descriptionController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _descriptionController = QuillController.basic();
    }

    _loadDepartments();
  }

  String _formatDateForField(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _loadDepartments() async {
    final departments = await JobPostingInjection.getJobDepartments();
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final j = widget.job;
    final descriptionHtml = QuillDescriptionCodec.encodeDocumentToHtml(
        _descriptionController.document);
    final updated = JobPostingModel(
      id: j.id,
      title: _jobTitleController.text.trim(),
      department: (_selectedDepartment ?? '').trim(),
      description: descriptionHtml,
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
      createdAt: j.createdAt,
    );
    try {
      await JobPostingInjection.updateJob(updated);
      if (!mounted) return;
      widget.onJobUpdated?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update job: $e')),
      );
    }
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
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Edit Job Posting', style: theme.textTheme.titleLarge),
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
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
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
                .map((e) => DropdownMenuItem<String>(
                    value: e.toLowerCase(),
                    child:
                        Text(e.substring(0, 1).toUpperCase() + e.substring(1))))
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
            Text('Update Job Posting',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.scaffoldBackgroundColor)),
          ],
        ),
      ),
    );
  }
}
