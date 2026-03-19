import 'dart:convert';
import 'dart:ui';

import 'package:employeeos/view/recruitment/data/index.dart'
    show
        JobPostingMockDatasource,
        JobPostingModel,
        getAllDepartmentNames,
        getPresetForDepartment,
        getStagePool;
import 'package:employeeos/view/recruitment/domain/index.dart'
    show JobPosting, PipelineStage;
import 'package:employeeos/view/recruitment/presentation/index.dart'
    show AdditionalDetailSection, DetailSection, ToolBar;
import '../components/common/save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class JobEditingPage extends StatefulWidget {
  final JobPosting job;

  const JobEditingPage({super.key, required this.job});

  @override
  State<JobEditingPage> createState() => _JobEditingPageState();
}

class _JobEditingPageState extends State<JobEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _jobTitleController = TextEditingController();
  String? _selectedDepartment;
  late QuillController _descriptionController;
  List<PipelineStage> _pipelineStages = [];
  List<String> get _departments => getAllDepartmentNames();

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
    _pipelineStages = j.pipeline != null && j.pipeline!.isNotEmpty
        ? List<PipelineStage>.from(j.pipeline!)
        : getPresetForDepartment(j.department);
    _locationController.text = j.location ?? '';
    _positionsController = TextEditingController(text: '${j.positions}');
    _lastDateController.text = _formatDateForField(j.lastDateToApply);
    _joiningType = j.joiningType;
    _isInternship = j.isInternship;
    _ctcRangeController.text = j.ctcRange ?? '';
    _postedByNameController.text = j.postedByName;
    _postedByEmailController.text = j.postedByEmail;

    if (j.description != null && j.description!.trim().isNotEmpty) {
      try {
        final doc = Document.fromJson(
          jsonDecode(j.description!) as List,
        );
        _descriptionController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _descriptionController = QuillController.basic();
      }
    } else {
      _descriptionController = QuillController.basic();
    }
  }

  String _formatDateForField(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final j = widget.job;
    final descriptionJson = jsonEncode(
      _descriptionController.document.toDelta().toJson(),
    );
    final updated = JobPostingModel(
      id: j.id,
      title: _jobTitleController.text.trim(),
      department: _selectedDepartment ?? '',
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
      createdAt: j.createdAt,
      pipeline: List<PipelineStage>.from(_pipelineStages),
    );
    JobPostingMockDatasource.instance.update(updated);
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
            onClick: _submit, theme: theme, text: 'Update Job Posting'));
  }
}
