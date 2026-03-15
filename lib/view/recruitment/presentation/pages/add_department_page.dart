// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:employeeos/core/index.dart'
    show CustomTextButton, CustomTextfield;
import 'package:employeeos/view/recruitment/data/mock/department_presets_mock.dart';
import 'package:employeeos/view/recruitment/domain/entities/pipeline_stage.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/add_posting/pipeline_section.dart';
import 'package:flutter/material.dart';

class AddDepartmentPage extends StatefulWidget {
  const AddDepartmentPage({super.key});

  @override
  State<AddDepartmentPage> createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  List<PipelineStage> _pipelineStages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      addDepartment(name, _pipelineStages);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text('Add Department', style: theme.textTheme.titleLarge),
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
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          children: [
            _buildDetailsCard(theme),
            const SizedBox(height: 24),
            _buildPipelineCard(theme),
            const SizedBox(height: 32),
            _buildSaveButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Department name and pipeline...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Department name',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: _nameController,
            theme: theme,
            hintText: 'e.g. Engineering, Marketing',
            keyboardType: TextInputType.text,
            onchange: (_) {},
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Department name is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pipeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stages used by default when creating jobs for this department.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          PipelineSection(
            theme: theme,
            stages: _pipelineStages,
            onChanged: (list) => setState(() => _pipelineStages = list),
            stagePool: getStagePool(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return CustomTextButton(
      onClick: _submit,
      backgroundColor: theme.colorScheme.tertiary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save, size: 20, color: theme.scaffoldBackgroundColor),
          const SizedBox(width: 8),
          Text(
            'Save Department',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
