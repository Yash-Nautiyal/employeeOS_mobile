// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ui';

import 'package:employeeos/view/recruitment/data/index.dart';
import 'package:employeeos/view/recruitment/domain/index.dart'
    show PipelineStage;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../index.dart'
    show AdditionalDetailSection, DetailSection, ToolBar;
import '../../../common/button/save_button.dart';

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
  List<PipelineStage> _pipelineStages = [];

  List<String> get _departments => getAllDepartmentNames();

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

    final descriptionJson = jsonEncode(
      _descriptionController.document.toDelta().toJson(),
    );

    final job = JobPostingModel(
      id: '',
      title: _jobTitleController.text.trim(),
      department: _selectedDepartment ?? '',
      description: descriptionJson,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      positions: int.tryParse(_positionsController.text.trim()) ?? 1,
      lastDateToApply: _lastDateController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_lastDateController.text.trim()),
      joiningType: _joiningType,
      isInternship: _isInternship,
      ctcRange: _ctcRangeController.text.trim().isEmpty
          ? null
          : _ctcRangeController.text.trim(),
      postedByName: _postedByNameController.text.trim(),
      postedByEmail: _postedByEmailController.text.trim(),
      createdAt: null,
      pipeline: List<PipelineStage>.from(_pipelineStages),
    );

    JobPostingMockDatasource.instance.create(job);
    Navigator.of(context).pop(true);
  }

  void _openDescriptionFullScreen() {
    setState(() => _isDescriptionFullScreenOpen = true);
    Navigator.of(context, rootNavigator: true)
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
                          Navigator.of(context, rootNavigator: true).pop(),
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
              onDepartmentChanged: (v) {
                setState(() {
                  _selectedDepartment = v;
                  _pipelineStages = v != null ? getPresetForDepartment(v) : [];
                });
              },
              pipelineStages: _pipelineStages,
              onPipelineChanged: (list) =>
                  setState(() => _pipelineStages = list),
              stagePool: getStagePool(),
            ),
            const SizedBox(height: 24),
            AdditionalDetailSection(
              theme: theme,
              locationController: _locationController,
              positionsController: _positionsController,
              lastDateController: _lastDateController,
              ctcRangeController: _ctcRangeController,
              postedByNameController: _postedByNameController,
              postedByEmailController: _postedByEmailController,
              joiningType: _joiningType,
              isInternship: _isInternship,
              onJoiningTypeChanged: (v) => setState(() => _joiningType = v),
              onIsInternshipChanged: (v) => setState(() => _isInternship = v),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SaveButton(
            onClick: _submit, theme: theme, text: 'Save Job Posting'));
  }
}
